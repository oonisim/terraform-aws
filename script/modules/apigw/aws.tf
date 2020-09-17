provider "aws" {
  region = var.REGION
  # access_key  = ${var.aws_access_key} # To be provided with AWS_ACCESS_KEY_ID  environment variable
}

#--------------------------------------------------------------------------------
# AWS data sources in the defined region
# Availability zones can differ depending on the region, hence retrieve facts.
# DO NOT hard-code e.g. AZ-A as there may not be 'AZ-A' in a region.
#--------------------------------------------------------------------------------
# The available AZs in the region defined in the provider will be retrieved into
# "aws_availability_zones" data source object.
data "aws_availability_zones" "all" {
}

data "aws_region" "current" {
}

#--------------------------------------------------------------------------------
# S3 bucket to upload project data to run the calculation on.
# Make sure the bucket is in the same region of running TF script to aviod an error.
# S3 is region specific (and TF S3 data source cannot specify the region).
# > Failed getting S3 bucket: BadRequest: Bad Request
#--------------------------------------------------------------------------------
data "aws_s3_bucket" "project" {
  bucket = var.bucket
}

data "aws_lambda_function" "signin" {
  function_name = var.lambda_signin_function_name
  qualifier     = var.lambda_signin_qualifier
}

data "aws_lambda_function" "create" {
  function_name = var.lambda_create_function_name
  qualifier     = var.lambda_create_qualifier
}

data "aws_lambda_function" "monitor" {
  function_name = var.lambda_monitor_function_name
  qualifier     = var.lambda_monitor_qualifier
}

data "aws_lambda_function" "delete" {
  function_name = var.lambda_delete_function_name
  qualifier     = var.lambda_delete_qualifier
}

