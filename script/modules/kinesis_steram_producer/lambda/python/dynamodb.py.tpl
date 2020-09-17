"""
Create/Update a job table with a record in the JSON format.

[JSON format]
{
    "id"            : <unique id of the job>
    "uid"           : <user id>
    "email"         : <user email>
    "creation_time" : <job creation time>
    "start_time"    : <job start time>
    "end_time"      : <job end time>
    "status"        : <job status>
    "ami"           : <EC2 AMI ID>
    "instance"      : <EC2 instance type>
}

[References]
https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/GettingStarted.Python.03.html
https://sysadmins.co.za/interfacing-amazon-dynamodb-with-python-using-boto3/
https://boto3.amazonaws.com/v1/documentation/api/latest/guide/dynamodb.html
"""
from __future__ import print_function

import sys
import os
import traceback
import json
import logging

import boto3

import job
import utility


# --------------------------------------------------------------------------------
# Globals via Terraform Interpolation
# --------------------------------------------------------------------------------
REGION = "${region}"
TABLE  = "${table}"

# --------------------------------------------------------------------------------
# Utility
# --------------------------------------------------------------------------------
def logger():
    """ Provide logger instance
    Return: logger instance
    """
    if not hasattr(logger, 'instance'):
        logger.instance = utility.get_logger(__file__)

    return logger.instance

def log_debug(message):
    """Log debug messages
    Args: debug message
    Returns: void
    """
    logger().debug("--------------------------------------------------------------------------------")
    logger().debug("In file [%s]", os.path.basename(__file__))
    logger().debug(message)

def log_exception(exception):
    """ Provide exception detail and stack trace.
    :Args:
        exception: Exception
    Returns: void
    """
    logger().error("--------------------------------------------------------------------------------")
    logger().error("In file [%s]", os.path.basename(__file__))
    logger().error("Exception [%s] [%s]", type(exception), str(exception))
    logger().error(traceback.format_exc())

def pretty_json(dictionary):
    """Generate formatted JSON
    Args: Python dictionary
    Returns: Formatted JSON
    """
    return utility.pretty_json(dictionary)

def log_result(action, response):
    """Print the action result executed on the table

    Args:
        action: Table action executed
        response: Action result
    Return:
        NA
    """
    logger().debug("--------------------------------------------------------------------------------")
    logger().debug("In file [%s]", os.path.basename(__file__))
    logger().debug(action + "\n" + pretty_json(response))


# --------------------------------------------------------------------------------
# Job database
# --------------------------------------------------------------------------------
def get_id(seed):
    """Generate a unique job id (seed + epoch time)

    Args:
        seed: input to generate na job id.

    Returns:
    """
    _id = job.JOB_DELIMITER.join((seed, str(utility.getEpoch())))
    return _id

def get_table():
    """DynamoDB table resource accessor

    Returns:
        Boto3 DynamoDB resource
    """
    if not hasattr(get_table, 'dynamo_table'):
        get_table.dynamo_table = boto3.resource('dynamodb', region_name=REGION).Table(TABLE)

    return get_table.dynamo_table

def validate(action, response):
    """Valiate the DynamoDB response
    Args:
      response: DynamoDB API response
    Raises: RuntimeError when response status code != 200

    """
    http_status = response['ResponseMetadata']['HTTPStatusCode']
    if http_status != 200:
        logger().error(
            "%s failed with status code [%s] with response [%s]",
            action,
            http_status,
            json.dumps(response)
        )
        raise RuntimeError("{0} failed with status code {1}".format(action, http_status))


def create(record):
    """Create a new job record
    Args:
        record: The table record to create

    Returns: Record created
    Raises:
        RuntimeError: Raise with the HTTP status code when put_item failed.

    """

    action = "DynamoDB put_item"
    item = {
        "id"            : get_id(record['uid']),
        "uid"           : record['uid'],
        "email"         : record['email'],
        "status"        : job.JOB_STATUS_CREATED,
        "creation_time" : utility.getEpoch()
    }
    response = get_table().put_item(
        Item=item,
        ReturnValues="ALL_OLD"

    )
    log_result(action, response)
    validate(action, response)

    return item


def start(record):
    """Update the job record on start

    Args
        record: Record content to update for the job to be started
    Returns: updated record (response['Attributes'])
    Raises:
        RuntimeError: Raise with the HTTP status code when put_item failed.
    """
    expression = """set
    #status =:status,
    start_time =:start_time,
    ami = :ami,
    instance = :instance
    """

    action = "DynamoDB update_item for start job"
    response = get_table().update_item(
        Key={
            'id': record['id'],
        },
        UpdateExpression=expression,
        ExpressionAttributeValues={
            ':status'       : job.JOB_STATUS_STARTED,
            ':start_time'   : record['start_time'],
            ':ami'          : record['ami'],
            ':instance'     : record['instance']
        },
        ExpressionAttributeNames={
            '#status': 'status',
        },
        ReturnValues="ALL_NEW"
    )
    log_result(action, response)
    validate(action, response)

    return response['Attributes']


def end(record):
    """Update the job record on end
    :param record: Record content to update for the completed job
    :return: updated record (response['Attributes'])
    """
    expression = """set
    #status =:status,
    end_time =:end_time
    """

    action = "DynamoDB update_item for end job"
    response = get_table().update_item(
        Key={
            'id': record['id'],
        },
        UpdateExpression=expression,
        ExpressionAttributeValues={
            ':status'       : job.JOB_STATUS_ENDED,
            ':end_time'     : record['end_time'],
        },
        ExpressionAttributeNames={
            '#status': 'status',
        },
        ReturnValues="ALL_NEW"
    )
    log_result(action, response)
    validate(action, response)

    return response['Attributes']


def get(record):
    """Read the job record
    :param record: A record with which to query the table
    :return: job record
    """

    item = None
    response = None
    action = "DynamoDB get_item"
    try:
        response = get_table().get_item(
            Key={
                'id': record['id'],
            }
        )
        item = response['Item']
    except Exception as exception:
        logger().error("DynamoDB get_item failed with record: [%s]", record)
        log_exception(exception)
        raise
    else:
        log_result(action, response)
        validate(action, response)

    return item

# --------------------------------------------------------------------------------
# Unit test
# --------------------------------------------------------------------------------
# noinspection Pylint
def test():
    """Unit test main
    """
    global REGION
    global TABLE
    log_levels = {
        "ERROR" : logging.ERROR,
        "WARN"  : logging.WARN,
        "INFO"  : logging.INFO,
        "DEBUG" : logging.DEBUG,
    }

    print("AWS region?")
    REGION = sys.stdin.readline().rstrip('\n')

    print("Dynamo table?")
    TABLE  = sys.stdin.readline().rstrip('\n')

    print("Log level (ERROR|WARN|INFO|DEBUG)?")
    logger().setLevel(log_levels[sys.stdin.readline().rstrip('\n')])

    record = {
        "uid"       : "user.onsihi",
        "email"     : "hoge@hoge.com",
        "start_time": utility.getEpoch(),
        "end_time"  : utility.getEpoch(),
        "ami"       : "ami_xxx",
        "instance"  : "t2.micro",
    }

    try:
        item = create(record)
        record['id'] = item['id']

        start(record)
        end(record)
        get(record)

    except Exception as exception:
        logger().error("Exceution failed with record [%s]", record)
        log_exception(exception)

if __name__ == '__main__':
    test()
