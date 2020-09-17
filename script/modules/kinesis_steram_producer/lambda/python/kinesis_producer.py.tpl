"""
Lambda function to steam data
"""
from __future__ import print_function

import sys
import os
import traceback

import datetime
import random
import signal
import string
import time
import uuid
import json

import boto3

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
# Terrafrm Interpolation
# --------------------------------------------------------------------------------
REGION = "${bucket_region}"
BUCKET = "${bucket_name}"
STREAM = "${stream_name}"

# --------------------------------------------------------------------------------
# Main
# --------------------------------------------------------------------------------
def get_instance():
    """Kinesis resource accessor

    Returns:
        Boto3 Kinesis stream client
    """
    if not hasattr(get_instance, 'kinesis_stream'):
        get_instance.kinesis_stream = boto3.client('kinesis', region_name=REGION)

    return get_instance.kinesis_stream

def validate(action, response):
    """Valiate the AWS API response
    Args:
      response: API response
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

def main(record):
    """
    """
    try:
        log_debug("Record = [" + pretty_json(record) + "]")

        response = get_instance().put_record(
            StreamName=STREAM,
            PartitionKey=record['id'],
            Data=json.dumps(record['data'])
        )
        log_debug("Kinesis put_record response = [" + pretty_json(response) + "]")
        validate("Kinesis put_record", response)
        return response

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
    """

    Args:
        event: Lambda event
        context: Lambda context

    Returns:

    """
    log_debug("Lambda event = [" + pretty_json(event) + "]")
    try:
        body = json.loads(event['body'])
        response = main(body)
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


def standalone():
    """Standalone kinesis producer
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

    RandomLength = 64

    epoch   = str(int(time.time()))
    id    = str(uuid.uuid4())
    rand    = "".join(random.choice(string.ascii_letters) for _ in range(RandomLength))
    record  = {
        "id":id,
        "time":epoch,
        "data":rand
    }

    event = {
        "headers": {
            "Authorization": "TBD",
            "Content-Type": "text/plain",
            "Via": "1.1 470917b83663a136083f105e2fd03290.cloudfront.net (CloudFront)",
            "CloudFront-Is-Desktop-Viewer": "true",
            "CloudFront-Is-SmartTV-Viewer": "false",
            "CloudFront-Forwarded-Proto": "https",
            "X-Forwarded-For": "59.100.168.81, 54.239.202.62",
            "CloudFront-Viewer-Country": "AU",
            "Accept": "*/*",
            "User-Agent": "PostmanRuntime/7.2.0",
            "X-Amzn-Trace-Id": "Root=1-5b922744-dc9ea90ce9533203a3de5f09",
            "X-Forwarded-Port": "443",
            "Host": "48hdhmryaf.execute-api.us-east-1.amazonaws.com",
            "X-Forwarded-Proto": "https",
            "X-Amz-Cf-Id": "gnK9QB7F0DctATpizImviEY71Xl8DpwauJrfrYs158bqCPW_4X54ag==",
            "CloudFront-Is-Tablet-Viewer": "false",
            "cache-control": "no-cache",
            "Postman-Token": "2f53c05a-578f-4e5f-bcc3-a0b064ba2a80",
            "CloudFront-Is-Mobile-Viewer": "false",
            "Accept-Encoding": "gzip, deflate"
        },
        "body": json.dumps(record)
    }
    response = lambda_handler(event, None)
    print(pretty_json(response))


if __name__ == '__main__':
    standalone()
