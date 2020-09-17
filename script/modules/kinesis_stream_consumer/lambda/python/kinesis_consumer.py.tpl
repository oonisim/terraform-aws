"""
Lambda function to stream data
"""
from __future__ import print_function

import sys
import os
import traceback

import signal
import string

import datetime
import time
import base64
import random
import uuid
import json

import boto3
from botocore.exceptions import ClientError

from utility import \
    pretty_json, \
    log_debug, \
    log_error, \
    log_exception, \
    validate

def Interrupt(signal, frame):
    print("\n")
    sys.exit(0)

signal.signal(signal.SIGINT, Interrupt)

# --------------------------------------------------------------------------------
# Globals
# --------------------------------------------------------------------------------
KINESIS_GET_RECORD_WAIT = 1     # Seconds to wait before calling next get_record.
KINESIS_GET_RECORD_HOLD = 5     # Seconds to wait when ProvisionedThroughputExceededException
RETRY_EXCEPTIONS = (
    'ProvisionedThroughputExceededException',
    'ThrottlingException'
)

# --------------------------------------------------------------------------------
# Interpolations (Terrafrm, etc)
# --------------------------------------------------------------------------------
REGION = "${bucket_region}" # S3 bucket region
BUCKET = "${bucket_name}"   # S3 bucket from which to load data.
STREAM = "${stream_name}"
TOPIC = "${topic_arn}"

# --------------------------------------------------------------------------------
# Boto3
# --------------------------------------------------------------------------------
def get_kinesis():
    """Kinesis resource accessor
    Returns:
        Boto3 Kinesis stream client
    """
    if not hasattr(get_kinesis, 'kinesis_stream'):
        get_kinesis.kinesis_stream = boto3.client('kinesis', region_name=REGION)

    return get_kinesis.kinesis_stream

def get_sns():
    """Kinesis resource accessor

    Returns:
        Boto3 Kinesis stream client
    """
    if not hasattr(get_sns, 'sns_topic'):
        get_sns.sns_topic = boto3.client('sns', region_name=REGION)

    return get_sns.sns_topic

def get_kinesis_shard_iterators(stream):
    """Return list of shard (stream partition) iterators, one for each shard of stream.
    Args:
        steam: kinesis stream name
    Returns:

    """
    shard_iterators = []

    response = get_kinesis().describe_stream(StreamName=stream)
    log_debug("kinesis:describe_stream response [{0}]".format(response))

    shards = response['StreamDescription']['Shards']
    for shard in shards:
        iterator = get_kinesis().get_shard_iterator(
            StreamName=stream,
            ShardId=shard['ShardId'],
            ShardIteratorType="LATEST"
        )
        log_debug("kinesis:get_shard_iterator itearator=[{0}]".format(iterator))
        shard_iterators.append(iterator)

    return shard_iterators

def get_records(iterator):
    """Get records from the shard
    Args:
        iterator: Shard iterator instance
    Returns:
        response: get_records() API response
    """
    log_debug("kinesis iterator [{0}]".format(iterator))
    response = get_kinesis().get_records(
        ShardIterator=iterator
    )
    log_debug("Kinesis get_record response = [{0}]".format(response))
    validate("Kinesis get_record", response)
    return response

def send_records(records):
    """Send records to the consumer
    Args:
        records: sending records
    Returns:
        None
    """
    log_debug("send_records: Number of records [{0}]".format(len(records)))
    for record in records:
        log_debug("publishing SNS a record [{0}]".format(pretty_json(record)))
        # --------------------------------------------------------------------------------
        # https://stackoverflow.com/questions/34029251/
        # --------------------------------------------------------------------------------
        response = get_sns().publish(
            TargetArn=TOPIC,
            Message=json.dumps({'default': pretty_json(record)}),
            MessageStructure='json'
        )
        validate("sns:publish", response)
        log_debug("SNS:publish response = [{0}]".format(response))

def iterate_shard(iterator):
    """Read records from a shard
    Args:
        iterator: Shard iterator
    Returns:
        Void
    """
    # --------------------------------------------------------------------------------
    # https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/kinesis.html
    # When you read repeatedly from a stream, use a GetShardIterator request
    # to get the first shard iterator for use in your first GetRecords request.
    # For subsequent reads use the new iterator returned by every GetRecords request
    # in NextShardIterator, which you use in the ShardIterator parameter of the next
    # GetRecords request.
    # --------------------------------------------------------------------------------
    next = iterator['ShardIterator']
    while next is not None:
        try:
            response = get_records(next)
            send_records(response["Records"])

            next = response['NextShardIterator']
            time.sleep(KINESIS_GET_RECORD_WAIT)

        except ClientError as exception:
            # --------------------------------------------------------------------------------
            # https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/kinesis.html
            # The size of the data returned by GetRecords depends on the utilization of the shard.
            # The maximum size is 10 MiB. If a call returns this amount, subsequent calls made within
            # the next 5 seconds throw ProvisionedThroughputExceededException .
            #
            # If there is insufficient provisioned throughput on the stream, subsequent calls within
            # the next 1 second throw ProvisionedThroughputExceededException
            # --------------------------------------------------------------------------------
            if exception.response['Error']['Code'] not in RETRY_EXCEPTIONS:
                raise
            else:
              log_debug("kinesis get_record: call exceeded provisioned throughput".format())
              time.sleep(KINESIS_GET_RECORD_HOLD)

    log_debug("exiting iter_shard...")


def iterate_shards(stream):
    """Iterate over all shards in the stream
    Args:
        stream: Kinesis stream to read data from
    Returns:
        Void
    """
    shard_iterators = get_kinesis_shard_iterators(stream)
    for iterator in shard_iterators:
        iterate_shard(iterator)

    log_debug("exiting iter_shardS...")

# --------------------------------------------------------------------------------
# Main
# --------------------------------------------------------------------------------
def main():

    """Read kinesis stream to foward date to the actual consumer.
    """
    try:
        iterate_shards(STREAM)

    except Exception as exception:
        log_debug("Exception in main.")
        log_exception(exception)
        raise

# --------------------------------------------------------------------------------
# Lambda
# --------------------------------------------------------------------------------
def lambda_response(response):
    """ Generate the response format that the AWS lambda service expects.
    Args:
        response: {
            "status_code"  : code,
            "content_type" : type,
            "content"      : content
        }

    Returns:
        Lambda response as the Kinesis response in the body.
    """
    return {
        "statusCode": response['status_code'],
        "headers": {
            "Content-Type": response['content_type']
        },
        "body": pretty_json(response['content']),
        "isBase64Encoded": False
    }

def lambda_handler(event, context):
    """AWS Lambda entry point
    Args:
        event: Lambda event
        context: Lambda context
   Returns:

    """
    log_debug("Lambda event = [" + pretty_json(event) + "]")
    try:
        # --------------------------------------------------------------------------------
        # https://docs.aws.amazon.com/lambda/latest/dg/with-kinesis.html
        # https://docs.aws.amazon.com/lambda/latest/dg/with-kinesis-create-package.html
        # --------------------------------------------------------------------------------
        records = []
        for record in event['Records']:
            #Kinesis data is base64 encoded so decode here
            payload=base64.b64decode(record["kinesis"]["data"])
            records.append(payload)
        send_records(records)

        return lambda_response({
            "status_code"   : 200,
            "content_type"  : "application/json",
            "content"       : response
        })

    except Exception as exception:
        log_error("Lambda execution failed")
        log_exception(exception)

        response = {
            "status_code"   : 500,
            "content_type"  : "application/json",
            "content"       : "Data sreaming lambda failed"
        }
        return lambda_response(response)

# --------------------------------------------------------------------------------
# Standalone
# --------------------------------------------------------------------------------
def standalone():
    """Unit test
    """
    global REGION
    print("AWS region?")
    REGION = sys.stdin.readline().rstrip('\n')

    global BUCKET
    print("S3 bucket name?")
    BUCKET  = sys.stdin.readline().rstrip('\n')

    global STREAM
    print("Kinesis stream name?")
    STREAM  = sys.stdin.readline().rstrip('\n')

    global TOPIC
    print("SNS topic name?")
    TOPIC  = sys.stdin.readline().rstrip('\n')

    try:
        while True:
            iterate_shards(STREAM)

    except Exception as exception:
        log_debug("Exception in test.")
        log_exception(exception)
        raise

if __name__ == '__main__':
    standalone()
