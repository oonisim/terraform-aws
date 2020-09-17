"""
Cognito JWT token utility based on AWS sample code
https://github.com/awslabs/aws-support-tools/tree/master/Cognito/decode-verify-jwt

Copyright 2017-2018 Amazon.com, Inc. or its affiliates. All Rights Reserved.
Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file
except in compliance with the License. A copy of the License is located at
#
    http://aws.amazon.com/apache2.0/
#
or in the "license" file accompanying this file. This file is distributed on an "AS IS"
BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
License for the specific language governing permissions and limitations under the License.
"""

import sys
import os
import traceback
import time

import json
import urllib
# --------------------------------------------------------------------------------
# Python-jose The JavaScript Object Signing and Encryption (JOSE) technologies
# https://github.com/mpdavis/python-jose
# --------------------------------------------------------------------------------
from jose import jwk, jwt
from jose.utils import base64url_decode

import utility

# --------------------------------------------------------------------------------
# Terraform interpolation
# --------------------------------------------------------------------------------
userpool = {
    "region": "${userpool_region}",
    "userpool_id": "${userpool_id}",
    "app_client_id": "${userpool_app_client_id}"
}

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
    logger().error("--------------------------------------------------------------------------------")

def pretty_json(dictionary):
    """Generate formatted JSON
    Args: Python dictionary
    Returns: Formatted JSON
    """
    return utility.pretty_json(dictionary)


# --------------------------------------------------------------------------------
# Cognito User Pool
# --------------------------------------------------------------------------------
def userpool_keys():
    """Generate cognito public keys

    Amazon Cognito generates a key pair of RSA keys for each user pool.
    The corresponding public key becomes available at an address in this format:
    https://cognito-idp.{region}.amazonaws.com/{userPoolId}/.well-known/jwks.json
    """

    region = userpool['region']
    userpool_id = userpool['userpool_id']
    app_client_id = userpool['app_client_id']
    keys_url = 'https://cognito-idp.{}.amazonaws.com/{}/.well-known/jwks.json'.format(region, userpool_id)
    log_debug(keys_url)
    # instead of re-downloading the public keys every time
    # we download them only on cold start
    # https://aws.amazon.com/blogs/compute/container-reuse-in-lambda/
    response = urllib.urlopen(keys_url)
    keys = json.loads(response.read())['keys']

    return keys

def decode(token):
    """Decode Cognito token
    Args:
        token: Token to identify the user
    Returns:
        User claims:
        {
           "sub":"95868e37-178e-4510-a3ab-ab9b1c3285f9",
           "event_id":"2c3daf0d-d329-11e8-97ee-71c97b54dc09",
           "token_use":"id",
           "iat":1539903442,
           "iss":"https://cognito-idp.us-east-1.amazonaws.com/us-east-1_b8goqWOhe",
           "exp":1539907042,
           "auth_time":1539903442,
           "cognito:username":"95868e37-178e-4510-a3ab-ab9b1c3285f9",
           "email":"",
           "aud":"laheqkakm9o7d8ssgai7v18qd"
        }
    Raises:
        RuntimeError with the cause as its message

    """

    # get the kid from the headers prior to verification
    headers = jwt.get_unverified_headers(token)
    kid = headers['kid']
    # search for the kid in the downloaded public keys
    keys = userpool_keys()
    key_index = -1
    for i in range(len(keys)):
        if kid == keys[i]['kid']:
            key_index = i
            break
    if key_index == -1:
        error = 'Public key not found in jwks.json'
        log_debug(error)
        raise RuntimeError(error)

    # construct the public key
    public_key = jwk.construct(keys[key_index])
    # get the last two sections of the token,
    # message and signature (encoded in base64)
    message, encoded_signature = str(token).rsplit('.', 1)
    # decode the signature
    decoded_signature = base64url_decode(encoded_signature.encode('utf-8'))
    # verify the signature
    if not public_key.verify(message.encode("utf8"), decoded_signature):
        error = 'Signature verification failed'
        log_debug(error)
        raise RuntimeError(error)

    log_debug('Signature successfully verified')
    # since we passed the verification, we can now safely
    # use the unverified claims
    claims = jwt.get_unverified_claims(token)
    # additionally we can verify the token expiration
    if time.time() > claims['exp']:
        error = 'Token is expired'
        log_debug(error)
        raise RuntimeError(error)

    # and the Audience  (use claims['client_id'] if verifying an access token)
    if claims['aud'] != userpool['app_client_id']:
        error = 'Token was not issued for this audience'
        log_debug(error)
        raise RuntimeError(error)

    # now we can use the claims
    log_debug(utility.pretty_json(claims))
    return claims


def lambda_handler(event, context):
    claims = False
    error = None

    try:
        token = event['token']
        claims = decode(token)
    except Exception as exception:
        log_exception(exception)

        claims = False
        error = "Lambda failed with {0}".format(str(exception))

    if claims is False:
        return {
            "statusCode": 500,
            "headers": {
               "Content-Type": "application/json"
            },
            "body": json.dumps({
                "error": error
            }),
            "isBase64Encoded": False
        }
    else:
        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json"
            },
            "body": json.dumps(claims),
            "isBase64Encoded": False
        }

def test():
    """Unit test main
    """
    # for testing locally you can enter the JWT ID Token here
    print("Token?\n")
    COGNITO_ID_TOKEN = sys.stdin.readline().rstrip('\n')

    event = {'token': COGNITO_ID_TOKEN}
    print(utility.pretty_json(lambda_handler(event, None)))


if __name__ == '__main__':
    test()
