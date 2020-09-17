terraform {
  backend "s3" {
    encrypt = true
  }
}

#--------------------------------------------------------------------------------
# Common/global configuration store
#--------------------------------------------------------------------------------
data "terraform_remote_state" "common" {
  backend = "s3"
  config = {
    encrypt = "true"
    bucket  = var.BACKEND_BUCKET
    key     = "${var.backend_key_common}"
  }
}

#--------------------------------------------------------------------------------
# VPC
#--------------------------------------------------------------------------------
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    encrypt = "true"
    bucket  = "${var.BACKEND_BUCKET}"
    key     = "${var.backend_key_vpc}"
  }
}

#--------------------------------------------------------------------------------
# LB
#--------------------------------------------------------------------------------
data "terraform_remote_state" "lb" {
  backend = "s3"
  config = {
    encrypt = "true"
    bucket  = "${var.BACKEND_BUCKET}"
    key     = local.backend_key_lb
  }
}

#--------------------------------------------------------------------------------
# Cognito Userpool IDP
#--------------------------------------------------------------------------------
data "terraform_remote_state" "cognito_idp" {
  backend = "s3"
  config = {
    encrypt = "true"
    bucket  = "${var.BACKEND_BUCKET}"
    key     = "${var.backend_key_cognito_idp}"
  }
}
/*
#--------------------------------------------------------------------------------
# Kinesis Firehose to send user click events to
#--------------------------------------------------------------------------------
data "terraform_remote_state" "kinesis_firehose" {
  backend = "s3"
  config = {
    encrypt = true
    bucket  = var.BACKEND_BUCKET
    key     = var.backend_key_kinesis_firehose
  }
}

#--------------------------------------------------------------------------------
# Questionnaire
#--------------------------------------------------------------------------------
data "terraform_remote_state" "questionnaire" {
  backend = "s3"
  config = {
    encrypt = "true"
    bucket  = "${var.BACKEND_BUCKET}"
    key     = "${var.backend_key_questionnaire}"
  }
}

#--------------------------------------------------------------------------------
# Recommendation
#--------------------------------------------------------------------------------
/*
data "terraform_remote_state" "questionnaire" {
  backend = "s3"
  config = {
    encrypt = "true"
    bucket  = "${var.BACKEND_BUCKET}"
    key     = "${var.backend_key_questionnaire}"
  }
}
*/