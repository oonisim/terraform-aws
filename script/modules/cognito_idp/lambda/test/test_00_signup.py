import json

import boto3

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
    boto_exception, \
    isExpectedInActual

from config_secret import COGNITO_TEMP_PASSWRD
import signin

from config import \
    JOB_ID, \
    INSTANCE_ID, \
    ID_TOKEN, \
    SUBSCRIPTION_ID, \
    EMAIL, \
    EMAIL_SOMEONE, \
    UID, \
    INSTANCE_TYPE


def test_signup():
    """Create/signup users in the identity pool for testing
    """
    try:
        email = EMAIL
        email_someone = EMAIL_SOMEONE
        response = signin.delete_user(email)
        response = signin.delete_user(email_someone)

    except Exception as exception:
        if "UserNotFoundException" in str(exception):
            pass

    response = signin.create_user(email_someone, COGNITO_TEMP_PASSWRD)
    log_debug("signup response is [{0}]".format(pretty_json(response)))

    response = signin.create_user(email, COGNITO_TEMP_PASSWRD)
    log_debug("signup response is [{0}]".format(pretty_json(response)))
