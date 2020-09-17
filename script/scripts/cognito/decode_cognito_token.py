#--------------------------------------------------------------------------------
# https://github.com/awslabs/aws-support-tools/tree/master/Cognito/decode-verify-jwt
# Copyright 2017-2018 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file
# except in compliance with the License. A copy of the License is located at
#
#     http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file. This file is distributed on an "AS IS"
# BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under the License.
#--------------------------------------------------------------------------------
import urllib
import json
import time

#--------------------------------------------------------------------------------
# Python-jose The JavaScript Object Signing and Encryption (JOSE) technologies
# https://github.com/mpdavis/python-jose
#--------------------------------------------------------------------------------
from jose import jwk, jwt
from jose.utils import base64url_decode

#--------------------------------------------------------------------------------
# Cognito public keys
#--------------------------------------------------------------------------------
# Amazon Cognito generates a key pair of RSA keys for each user pool.
# The corresponding public key becomes available at an address in this format:
# https://cognito-idp.{region}.amazonaws.com/{userPoolId}/.well-known/jwks.json
#--------------------------------------------------------------------------------
def userpool_keys(userpool):
    region = userpool['region']
    userpool_id = userpool['userpool_id']
    app_client_id = userpool['app_client_id']
    keys_url = 'https://cognito-idp.{}.amazonaws.com/{}/.well-known/jwks.json'.format(region, userpool_id)
    print(keys_url)
    # instead of re-downloading the public keys every time
    # we download them only on cold start
    # https://aws.amazon.com/blogs/compute/container-reuse-in-lambda/
    response = urllib.urlopen(keys_url)
    keys = json.loads(response.read())['keys']

    print(keys)
    return keys

#--------------------------------------------------------------------------------
# Decode Cognito token
#--------------------------------------------------------------------------------
def decode(token, userpool):
    # get the kid from the headers prior to verification
    headers = jwt.get_unverified_headers(token)
    kid = headers['kid']
    # search for the kid in the downloaded public keys
    keys = userpool_keys(userpool)
    key_index = -1
    for i in range(len(keys)):
        if kid == keys[i]['kid']:
            key_index = i
            break
    if key_index == -1:
        print('Public key not found in jwks.json')
        return False
    # construct the public key
    public_key = jwk.construct(keys[key_index])
    # get the last two sections of the token,
    # message and signature (encoded in base64)
    message, encoded_signature = str(token).rsplit('.', 1)
    # decode the signature
    decoded_signature = base64url_decode(encoded_signature.encode('utf-8'))
    # verify the signature
    if not public_key.verify(message.encode("utf8"), decoded_signature):
        print('Signature verification failed')
        return False
    print('Signature successfully verified')
    # since we passed the verification, we can now safely
    # use the unverified claims
    claims = jwt.get_unverified_claims(token)
    # additionally we can verify the token expiration
    if time.time() > claims['exp']:
        print('Token is expired')
        #return False
    # and the Audience  (use claims['client_id'] if verifying an access token)
    if claims['aud'] != userpool['app_client_id'] :
        print('Token was not issued for this audience')
        return False
    # now we can use the claims
    print(json.dumps(claims))
    return claims


#--------------------------------------------------------------------------------
# For use with AWS lambda
#--------------------------------------------------------------------------------
def lambda_handler(event, context):
    token = event['token']
    userpool = {
        "region": "us-east-1",
        "userpool_id": "us-east-1_Ao9bRYkPj",
        "app_client_id": "5gt247c48g6gog50bq3dn0jfp3"
    }
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(decode(token, userpool)),
        "isBase64Encoded": False
    }

#--------------------------------------------------------------------------------
# Main for test
#--------------------------------------------------------------------------------
if __name__ == '__main__':
    # for testing locally you can enter the JWT ID Token here
    event = {'token': 'eyJraWQiOiJCMDdkSXhROXE0Wm5IdHpubzIwK2JEUFZ3dENpeldSampNQm9ETWFrRHU0PSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiJhNWRlYjViMy0yMjE3LTQ1ZmEtYTYwZS0zY2Q5Y2I0NjBiOTgiLCJhdWQiOiI1Z3QyNDdjNDhnNmdvZzUwYnEzZG4wamZwMyIsImV2ZW50X2lkIjoiZDZjMTU4NTctZDVjYy0xMWU4LWJjZDctMWZhMWIzYjIwMDgxIiwidG9rZW5fdXNlIjoiaWQiLCJhdXRoX3RpbWUiOjE1NDAxOTM2MzgsImlzcyI6Imh0dHBzOlwvXC9jb2duaXRvLWlkcC51cy1lYXN0LTEuYW1hem9uYXdzLmNvbVwvdXMtZWFzdC0xX0FvOWJSWWtQaiIsImNvZ25pdG86dXNlcm5hbWUiOiJhNWRlYjViMy0yMjE3LTQ1ZmEtYTYwZS0zY2Q5Y2I0NjBiOTgiLCJleHAiOjE1NDAxOTcyMzgsImlhdCI6MTU0MDE5MzYzOCwiZW1haWwiOiJtYXNheXVraS5vbmlzaGlAcmlvdGludG8uY29tIn0.apjrB2zxTvDCS2ZMaz1_CMPZfyiENkxeb0hi-QXj9bd4myVwsEL9JMqAw305umpAwM_Z60WbLy1ydIO40rR-wMq-DPfrMLuxLjenQEmjjdjOO3DSgf1xdcrmJIGKw19RYtejros68JdCp1P3bzl0o0ZTBmDyXxqRtxQaPuB8w2qiiY5cmUoIGrYXaKw5QJwjMjT3mb-VQiMR46oKlAAnhVPqkPeMHIDIv2zBwTO_FPvR3jjJs9WkAQCaOUU7IBCVBUIgwsFv9qJQuYH7BgcpI34TGQCSxXy-LmW9bUlWw20gPzJIviNJ5CLVe39ZlB7R--cAQtGAzgBBD8Dfu7T5sQ'}
    lambda_handler(event, None)