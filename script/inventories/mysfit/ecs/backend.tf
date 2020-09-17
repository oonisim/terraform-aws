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
# ASG
#--------------------------------------------------------------------------------
data "terraform_remote_state" "asg" {
  backend = "s3"
  config = {
    encrypt = "true"
    bucket  = "${var.BACKEND_BUCKET}"
    key     = var.backend_key_asg
  }
}

