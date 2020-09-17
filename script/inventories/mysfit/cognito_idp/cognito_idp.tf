#--------------------------------------------------------------------------------
# API.
# "API" represents a business domain under which business functions/features
# are defined as "Resources".
#--------------------------------------------------------------------------------
module "identity" {
  source = "../../../modules/cognito_idp"

  PROJECT = var.PROJECT
  ENV     = var.ENV
  REGION  = var.REGION

  # Cognito Userpool name
  name = var.identity_provider_name

  allow_admin_create_user_only = var.allow_admin_create_user_only
  # Email or Phone Verification
  auto_verified_attributes = var.auto_verified_attributes

  # Client Secret
  # JavaScript SDK does not support Client Secret. Hence if it is enabled,
  # it casues "Unable to verify secret hash for client".
  enable_client_secret = var.enable_client_secret

  # Bucket to upload artefacts
  bucket = local.bucket_name
}

