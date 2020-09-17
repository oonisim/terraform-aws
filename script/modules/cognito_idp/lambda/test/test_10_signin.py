import json

import pytest

import signin
from identity_constants import \
    IDENTITY_ERROR_USER_NOT_EXIST, \
    IDENTITY_ERROR_INCORRECT_CREDENTIAL, \
    IDENTITY_ERROR_TOKEN_EXPIRED, \
    IDENTITY_ERROR_TOKEN_SIGN_KEY_NOT_FOUND, \
    IDENTITY_ERROR_TOKEN_SIGNATURE_NO_MATCH, \
    IDENTITY_ERROR_TOKEN_INVALID

from utility import \
    FILEPATH_SEPARATOR, \
    interrupt_handler, \
    getEpoch, \
    atimer, \
    load_json_file, \
    pretty_json, \
    log_debug, \
    log_error, \
    log_exception, \
    validate, \
    boto_exception

from config import \
    JOB_ID, \
    INSTANCE_ID, \
    ID_TOKEN, \
    REFRESH_TOKEN, \
    AUTHENTICATED_TIME, \
    ID_TOKEN_EXPIRED, \
    REFRESH_TOKEN_EXPIRED, \
    SUBSCRIPTION_ID, \
    EMAIL, \
    EMAIL_SOMEONE, \
    UID, \
    INSTANCE_TYPE


from config_secret import COGNITO_TEMP_PASSWRD

# To test giving invalid token from someone else.
credential_signin_someone = {
    "username": EMAIL_SOMEONE,
    "password": COGNITO_TEMP_PASSWRD
}

credential_signin_normal = {
    "username": EMAIL,
    "password": COGNITO_TEMP_PASSWRD
}

credential_signin_error_invalid_username = {
    "username": "invalid@,
    "password": COGNITO_TEMP_PASSWRD
}

credential_signin_error_invalid_password = {
    "username": EMAIL,
    "password": "invalid"
}

credential_refresh_normal = {
    "username": EMAIL,
    "IdToken": "",
    "RefreshToken": ""
}

credential_refresh_token_expired_normal = {
    "username": EMAIL,
    "IdToken": ID_TOKEN_EXPIRED,
    # RefreshToken lasts 30 days. Need to wait 30 days?
    "RefreshToken": REFRESH_TOKEN
}

credential_refresh_error_token_expired = {
    "username": EMAIL,
    "IdToken": ID_TOKEN_EXPIRED,
    # RefreshToken lasts 30 days. Need to wait 30 days?
    "RefreshToken": REFRESH_TOKEN_EXPIRED
}

credential_refresh_error_token_invalid = {
    "username": "non_match_user@,
    # ID token for someone else
    "IdToken": "TO BE UPDATED in test_decode_someones_token",
    "RefreshToken": REFRESH_TOKEN
}


def test_decode_someones_token():
    """Verify decoding Cognito token (JWT)
    {
       "sub":"95868e37-178e-4510-a3ab-ab9b1c3285f9",
       "event_id":"2c3daf0d-d329-11e8-97ee-71c97b54dc09",
       "token_use":"id",
       "iat":1539903442,
       "iss":"https://cognito-idp.us-east-1.amazonaws.com/us-east-1_b8goqWOhe",
       "exp":1539907042,
       "auth_time":1539903442,
       "cognito:username":"95868e37-178e-4510-a3ab-ab9b1c3285f9",
       "email":EMAIL,
       "aud":"laheqkakm9o7d8ssgai7v18qd"
    }
    """
    response = signin.authenticate(credential_signin_someone)
    id_token = response['AuthenticationResult']['IdToken']

    decoded = signin.decode(id_token)
    assert decoded['email'] == credential_signin_someone['username']

    global credential_refresh_error_token_invalid
    credential_refresh_error_token_invalid['IdToken'] = id_token


def test_signin_normal():
    event = {
        "body": json.dumps(credential_signin_normal)
    }
    response = signin.lambda_handler(event, None)
    assert response['statusCode'] == 200

    tokens = json.loads(response['body'])
    global credential_refresh_normal
    credential_refresh_normal['IdToken'] = tokens['IdToken']
    credential_refresh_normal['RefreshToken'] = tokens['RefreshToken']


def test_signin_error_invalid_username():
    """Verify signin fails with an invalid (non-existing) username.
    """
    event = {
        "body": json.dumps(credential_signin_error_invalid_username)
    }
    response = signin.lambda_handler(event, None)
    body = json.loads(response['body'])
    assert \
        response['statusCode'] == 500 and \
        IDENTITY_ERROR_USER_NOT_EXIST in body['message']


def test_signin_error_invalid_password():
    """Verify signin fails with an invalid password
    """
    event = {
        "body": json.dumps(credential_signin_error_invalid_password)
    }
    response = signin.lambda_handler(event, None)
    body = json.loads(response['body'])
    assert \
        response['statusCode'] == 500 and \
        IDENTITY_ERROR_INCORRECT_CREDENTIAL in body['message']


def test_refresh_normal():
    """Verify refresh token succeeds
    """
    # signin and get tokens
    event = {
        "body": json.dumps(credential_signin_normal)
    }
    response = signin.lambda_handler(event, None)
    assert response['statusCode'] == 200

    global credential_refresh_normal
    credential_refresh_normal = json.loads(response['body'])

    # Refresh tokens
    event = {
        "body": json.dumps(credential_refresh_normal)
    }
    response = signin.lambda_handler(event, None)
    assert response['statusCode'] == 200

    tokens = json.loads(response['body'])
    assert tokens['RefreshToken'] == credential_refresh_normal['RefreshToken']


@pytest.mark.skip(reason="If Cognito Userpool is recreated, this will fail with [Signing key not found]")
def test_refresh_expired_token_normal():
    """Verify refresh expired valid token succeeds"""
    event = {
        "body": json.dumps(credential_refresh_token_expired_normal)
    }
    response = signin.lambda_handler(event, None)
    assert response['statusCode'] == 200

    tokens = json.loads(response['body'])
    assert tokens['RefreshToken'] == credential_refresh_token_expired_normal['RefreshToken']


@pytest.mark.skip(reason="Need to wait 30 days for RefreshToken to expire")
def test_refresh_error_refresh_token_expired():
    """Verify ID token refresh with expired Refresh Token fails"""
    event = {
        "body": json.dumps(credential_refresh_error_token_expired)
    }
    response = signin.lambda_handler(event, None)
    body = json.loads(response['body'])
    assert \
        response['statusCode'] == 500 and \
        body['message'] == IDENTITY_ERROR_TOKEN_EXPIRED


def test_refresh_error_token_invalid():
    """Verify refresh ID token of someone else fails for the user """
    event = {
        "body": json.dumps(credential_refresh_error_token_invalid)
    }
    response = signin.lambda_handler(event, None)
    body = json.loads(response['body'])
    assert \
        response['statusCode'] == 500 and \
        body['message'] == IDENTITY_ERROR_TOKEN_INVALID


