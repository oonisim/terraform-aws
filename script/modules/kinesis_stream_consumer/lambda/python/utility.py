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

#--------------------------------------------------------------------------------
# Get Epoch time
#--------------------------------------------------------------------------------
def getEpoch():
    return int(time.time())

#--------------------------------------------------------------------------------
# JSON.
#--------------------------------------------------------------------------------
class DecimalEncoder(json.JSONEncoder):
    def default(self, o):
        if isinstance(o, decimal.Decimal):
            if o % 1 > 0:
                return float(o)
            else:
                return int(o)
        return super(DecimalEncoder, self).default(o)

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


#--------------------------------------------------------------------------------
# Logger
#--------------------------------------------------------------------------------
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
        logger.setLevel(logging.DEBUG)
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
            json.dumps(response)
        )
        raise RuntimeError("{0} failed with status code {1}".format(action, http_status))

