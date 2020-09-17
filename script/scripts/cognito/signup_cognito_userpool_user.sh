#!/usr/bin/env bash
#--------------------------------------------------------------------------------
# Script to sign up a Cognito User Pool user.
#--------------------------------------------------------------------------------
# [Notes]
# There is no way for an administrator to sign-up a user in one step.
# https://stackoverflow.com/questions/40287012/how-to-change-user-status-force-change-password
# Need to go through the user state transfer as in the AWS document.
# https://docs.aws.amazon.com/cognito/latest/developerguide/signing-up-users-in-your-app.html
#--------------------------------------------------------------------------------
set -eu
DIR=$(realpath $(dirname $0))
cd ${DIR}

#--------------------------------------------------------------------------------
# Parameters for AWS CLI cognito-idp to signup a user.
#--------------------------------------------------------------------------------
TEMP_PASSWRD='3%YxXbnAY5G^UPX^v3b-9m+vxVmFRv7d'

echo "email of the user? (used as the username)"
read EMAIL

echo "Password to set?"
read PASSWORD

echo "AWS region?"
read REGION

echo "Cognito User Pool ID?"
read USER_POOL_ID

echo "Cognito User Pool Client ID?"
read USER_POOL_CLIENT_ID

echo "Cognito User Pool Client Secret?"
read USER_POOL_CLIENT_SECRET


#--------------------------------------------------------------------------------
# Create a user in Cognito User Pool.
# admin-create-user transfer the user state to FORCE_CHANGE_PASSWORD.
#--------------------------------------------------------------------------------
USERNAME=$(aws cognito-idp admin-create-user \
  --user-pool-id ${USER_POOL_ID} \
  --username "${EMAIL}" \
  --temporary-password "${TEMP_PASSWRD}" \
  --user-attributes Name=email,Value="${EMAIL}" \
  --message-action "SUPPRESS" \
  --region "${REGION}" \
| jq  -r .User.Username)

USERNAME=${USERNAME:?"Need to set USERNAME non-empty"}


#--------------------------------------------------------------------------------
# Create SECRET_HASH
# https://docs.aws.amazon.com/cognito/latest/developerguide/signing-up-users-in-your-app.html#cognito-user-pools-computing-secret-hash
#--------------------------------------------------------------------------------
SECRET_HASH=$(python compute_secret_hash.py \
  "${USERNAME}" \
  "${USER_POOL_CLIENT_ID}" \
  "${USER_POOL_CLIENT_SECRET}")

SECRET_HASH=${SECRET_HASH:?"Need to set SECRET_HASH non-empty"}

#--------------------------------------------------------------------------------
# Initiate the password change challenge.
# admin-initiate-auth returns the NEW_PASSWORD_REQUIRED challenge.
#--------------------------------------------------------------------------------
SESSION_TOKEN=$(aws cognito-idp admin-initiate-auth \
  --region "${REGION}" \
  --user-pool-id "${USER_POOL_ID}" \
  --client-id "${USER_POOL_CLIENT_ID}" \
  --auth-flow ADMIN_NO_SRP_AUTH \
  --auth-parameters USERNAME="${USERNAME}",PASSWORD="${TEMP_PASSWRD}",SECRET_HASH="${SECRET_HASH}" \
| jq -r .Session)

SESSION_TOKEN=${SESSION_TOKEN:?"Need to set SESSION_TOKEN non-empty"}

#--------------------------------------------------------------------------------
# Response to the NEW_PASSWORD_REQUIRED challenge.
#--------------------------------------------------------------------------------
aws cognito-idp admin-respond-to-auth-challenge \
  --region "${REGION}" \
  --user-pool-id "${USER_POOL_ID}" \
  --client-id "${USER_POOL_CLIENT_ID}" \
  --challenge-name NEW_PASSWORD_REQUIRED \
  --challenge-responses USERNAME="${USERNAME}",NEW_PASSWORD="${PASSWORD}",SECRET_HASH="${SECRET_HASH}" \
  --session "${SESSION_TOKEN}"

