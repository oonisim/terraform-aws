#--------------------------------------------------------------------------------
# Project
#--------------------------------------------------------------------------------
variable "PROJECT" {
}

variable "ENV" {
}

variable "REGION" {
  description = "AWS region to be set via the TF_VAR enviornment variable"
}

variable "name" {
  description = "Identity pool name"
}

variable "allow_admin_create_user_only" {
  description = "(Optional) If only the administrator is allowed to create user profiles. Set to False if users can sign themselves up via an app."
  default = true
}
#--------------------------------------------------------------------------------
# Email or Phone Verification
# Amazon Cognito can automatically verify email addresses or mobile phone numbers by sending a verification code
# https://docs.aws.amazon.com/cognito/latest/developerguide/user-pool-settings-email-phone-verification.html
#--------------------------------------------------------------------------------
variable "auto_verified_attributes" {
  description = "(Optional) The attributes to be auto-verified. Possible values: email, phone_number."
  type = list(string)
  default = []
}

#--------------------------------------------------------------------------------
# Cognito Usepool Client Secret
# When you create an app, you can optionally choose to create a secret for that app.
# If a secret is created for the app, the secret must be provided to use the app.
# https://docs.aws.amazon.com/cognito/latest/developerguide/user-pool-settings-client-apps.html
#
# SecretHash value is a Base 64-encoded keyed-hash message authentication code (HMAC)
# calculated using the secret key of a user pool client and username plus the client ID.
# https://docs.aws.amazon.com/cognito/latest/developerguide/signing-up-users-in-your-app.html#cognito-user-pools-computing-secret-hash
#
# The Javascript SDK doesn't support Apps with a Client Secret.
# Need to disable "Generate client secret" when creating a User Pool.
# Error "Unable to verify secret hash for client in Amazon Cognito Userpools"
# https://stackoverflow.com/questions/37438879/unable-to-verify-secret-hash-for-client-in-amazon-cognito-userpools
#--------------------------------------------------------------------------------
variable "enable_client_secret" {
  description = "Optionally create a secret for User Pool client secret or not. Disable it for Javascript JDK."
  default = true
}

#--------------------------------------------------------------------------------
# S3 bucket
# - To presign to upload the project data.
# - To upload packages e.g. lambda function packages
#--------------------------------------------------------------------------------
variable "bucket" {
  description = "S3 bucket to load the data for execution"
}

