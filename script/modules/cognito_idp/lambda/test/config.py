from decimal import *
# --------------------------------------------------------------------------------
# Token would not work if the cognito user is recreated
# --------------------------------------------------------------------------------
ID_TOKEN = ""
ID_TOKEN_EXPIRED = ""
JOB_ID = None  # ID to be generated at created and re-used subsequent calls.
INSTANCE_ID = None
REFRESH_TOKEN = ""
AUTHENTICATED_TIME = 1549437029  # Must match with that in ID_TOKEN
REFRESH_TOKEN_EXPIRED = None
SUBSCRIPTION_ID = "arn:aws:sns:us-east-1:675450155784:"
EMAIL = "hoge@gmail.com"
EMAIL_SOMEONE = "hoge@gmail.com"
UID = "****"
INSTANCE_TYPE = "t2.micro"
SPOT_PRICE=Decimal(str(0.001))
