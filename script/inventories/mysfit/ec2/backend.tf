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
    bucket  = var.BACKEND_BUCKET
    key     = "${var.backend_key_vpc}"
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
# ECS
#
# [Cyclic Dependency]
# ECS Agent on EC2 needs to know the ECS cluster name to join.
# ECS cluster needs to know ASG to setup its capacity provide.
#
# Provide the ECS cluster name from global parameters.
#--------------------------------------------------------------------------------
/*
data "terraform_remote_state" "ecs" {
  backend = "s3"
  config = {
    encrypt = "true"
    bucket  = var.BACKEND_BUCKET
    key     = "${var.backend_key_ecs}"
  }
}
*/