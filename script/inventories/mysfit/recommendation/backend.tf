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
# S3
#--------------------------------------------------------------------------------
data "terraform_remote_state" "s3" {
  backend = "s3"
  config = {
    encrypt = "true"
    bucket  = var.BACKEND_BUCKET
    key     = var.backend_key_s3
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
# API GW
#--------------------------------------------------------------------------------
data "terraform_remote_state" "apigw" {
  backend = "s3"
  config = {
    encrypt = "true"
    bucket  = "${var.BACKEND_BUCKET}"
    key     = "${var.backend_key_apigw}"
  }
}

#--------------------------------------------------------------------------------
# Kinesis Firehose to send user click events to
#--------------------------------------------------------------------------------
data "terraform_remote_state" "sagemaker" {
  backend = "s3"
  config = {
    encrypt = true
    bucket  = var.BACKEND_BUCKET
    key     = var.backend_key_sagemaker
  }
}


