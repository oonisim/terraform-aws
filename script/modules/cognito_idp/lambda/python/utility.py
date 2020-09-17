from __future__ import print_function # Python 2/3 compatibility
import os
import sys
import traceback
import time
import decimal
import json
import logging
import inspect
from inspect import getframeinfo, currentframe
from datetime import date, datetime
from functools import wraps
import botocore

# --------------------------------------------------------------------------------
# Constants
# --------------------------------------------------------------------------------
FILEPATH_SEPARATOR = os.sep
LOG_LEVEL = logging.DEBUG


def interrupt_handler(signal, frame):
    """
    # System interrupt handler
    """
    print("\n")
    sys.exit(0)

def getEpoch():
    """
    Get Epoch time
    """
    return int(time.time())



# --------------------------------------------------------------------------------
# Dictionary
# --------------------------------------------------------------------------------
import collections
def flatten(d, parent_key='', sep='_'):
    items = []
    for k, v in d.items():
        new_key = parent_key + sep + k if parent_key else k
        if isinstance(v, collections.MutableMapping):
            items.extend(flatten(v, new_key, sep=sep).items())
        else:
            items.append((new_key, v))
    return dict(items)


def isExpectedInActual(expected, actual):
    """
    Verify if expected item is in actual as well (expected <= actual)
    :param expected:
    :param actual:
    :return: boolean
    """
    expected_flat = flatten(expected)
    expected_keys = expected_flat.keys()
    actual_flat = flatten(actual)

    verdict = True

    for key in expected_keys:
        if key not in actual_flat:
            verdict = False
            log_debug("key [{0}] in expected job record not in the actual".format(key))
        if expected_flat[key] != actual_flat[key]:
            verdict = False
            log_debug("key [{0}] values differ. Expected [{1}] Actual [{2}]".format(
                key,
                expected_flat[key],
                actual_flat[key]
            ))
    return verdict


# --------------------------------------------------------------------------------
# JSON.
# --------------------------------------------------------------------------------
"""
class DecimalEncoder(json.JSONEncoder):
    def default(self, o):
        if isinstance(o, decimal.Decimal):
            if o % 1 > 0:
                return float(o)
            else:
                return int(o)
        return super(DecimalEncoder, self).default(o)
"""

def json_serial(obj):
    """JSON serializer for objects not serializable by default json code
        Args:
            obj: object to serialize into JSON
    """
    _serialize = {
        "int"       : lambda o: int(o),
        "float"     : lambda o: float(o),
        "decimal"   : lambda o: float(o) if o % 1 > 0 else int(o),
        "date"      : lambda o: o.isoformat(),
        "datetime"  : lambda o: o.isoformat(),
        "str"       : lambda o: o,
    }
    return _serialize[type(obj).__name__.lower()](obj)


def pretty_json(dict):
    """
    Pretty print Python dictionary
    Args:
        dict: Python dictionary
    Returns:
        Pretty JSON
    """
    #return json.dumps(dict, indent=4, cls=DecimalEncoder)
    #return json.dumps(my_dictionary, indent=4, sort_keys=True, default=str)

    return json.dumps(dict, indent=2, default=json_serial, sort_keys=True, )


def load_json_file(file):
    """
    Load configurations from JSON file
    Args:
        file: JSON filename
    Returns:
        Python dictionary
    """
    try:
        with open(file) as conf_json:
            conf = json.load(conf_json)
        return conf

    except:
        print("Unexpected error: {0}".format(sys.exc_info()[0]))
        raise


# --------------------------------------------------------------------------------
# Logger
# --------------------------------------------------------------------------------
logger = None
def get_logger():
    """Get logger instance for the caller module
    Returns:
        Logger instancce
    """

    py = os.path.splitext(__name__)[0]
    this = getframeinfo(currentframe()).function
    if not hasattr(get_logger, py):
        logger = logging.getLogger(py)
        logger.setLevel(LOG_LEVEL)
        logger.addHandler(logging.StreamHandler())
        setattr(get_logger, py, logger)

    return getattr(get_logger, py)


def log_debug(message):
    """Log debug messages
    Args: debug message
    Returns: void
    """
    # https://docs.python.org/3/library/inspect.html
    (filename, line_number, function_name, lines, index) = inspect.getframeinfo(inspect.currentframe().f_back)
    get_logger().debug("--------------------------------------------------------------------------------")
    get_logger().debug("In file [%s] function [%s] line [%d]",
                       os.path.basename(filename),
                       function_name,
                       line_number
                       )
    get_logger().debug(message)


def log_error(message):
    """Log debug messages
    Args: debug message
    Returns: void
    """
    # https://docs.python.org/3/library/inspect.html
    (filename, line_number, function_name, lines, index) = inspect.getframeinfo(inspect.currentframe().f_back)
    get_logger().error("--------------------------------------------------------------------------------")
    get_logger().error("In file [%s] function [%s] line [%d]",
                       os.path.basename(filename),
                       function_name,
                       line_number
                       )
    get_logger().error(message)


def log_exception(exception):
    """ Provide exception detail and stack trace.
    :Args:
        exception: Exception
    Returns: void
    """
    # https://docs.python.org/3/library/inspect.html
    (filename, line_number, function_name, lines, index) = inspect.getframeinfo(inspect.currentframe().f_back)
    get_logger().error("--------------------------------------------------------------------------------")
    get_logger().error("In file [%s] function [%s] line [%d]",
                       os.path.basename(filename),
                       function_name,
                       line_number
                       )
    get_logger().error("Exception [%s] [%s]", type(exception), str(exception))
    get_logger().error(traceback.format_exc())


# --------------------------------------------------------------------------------
# Decorators
# --------------------------------------------------------------------------------
def atimer(func):
    """Print the runtime of the decorated function"""
    @wraps(func)
    def wrapper(*args, **kwargs):
        start_time = time.time()    # 1

        value = func(*args, **kwargs)

        end_time = time.time()
        run_time = end_time - start_time    # 3
        log_debug("[{0}] Finished in [{1}] secs".format(
            func.__name__,
            run_time
        ))
        return value

    return wrapper


# --------------------------------------------------------------------------------
# AWS
# --------------------------------------------------------------------------------
def validate(action, response):
    """Valiate the AWS API response
    Args:
      response: API response
    Raises: RuntimeError when response status code != 200

    """
    http_status = response['ResponseMetadata']['HTTPStatusCode']
    if http_status != 200:
        get_logger().error(
            "%s failed with status code [%s] with response [%s]",
            action,
            http_status,
            pretty_json(response)
        )
        raise RuntimeError("{0} failed with status code {1}".format(action, http_status))


def boto_exception(aws_function):
    """Decorator to handle Botocore exception(s)
    """
    @wraps(aws_function)
    def wrapper(*args, **kwds):
        try:
            #log_debug("boto3_exception calling [{0}]".format(aws_function.__name__))
            return aws_function(*args, **kwds)

        except botocore.exceptions.ClientError as exception:
            log_error(
                "[{0}] failed. boto3 response [{1}]".format(
                    aws_function.__name__,
                    pretty_json(exception.response)
                )
            )
            log_exception(exception)
            raise RuntimeError("Failed at AWS API call. Code [{0}] Message [{1}] RequestID [{2}]".format(
                exception.response['Error']['Code'],
                exception.response['Error']['Message'],
                exception.response['ResponseMetadata']['RequestId']
            ))

    return wrapper
