/*
provider "aws" {
  region      = var.REGION
  # access_key  = ${var.aws_access_key} # To be provided with AWS_ACCESS_KEY_ID  environment variable
}
*/
#--------------------------------------------------------------------------------
# AWS data sources in the defined region
# Availability zones can differ depending on the region, hence retrieve facts.
# DO NOT hard-code e.g. AZ-A as there may not be 'AZ-A' in a region.
#--------------------------------------------------------------------------------
# The available AZs in the region defined in the provider will be retrieved into
# "aws_availability_zones" data source object.
data "aws_availability_zones" "all" {}
data "aws_region" "current" {}


#--------------------------------------------------------------------------------
# S3 bucket to upload project data to run the prediction on.
# Make sure the bucket is in the same region of running TF script to aviod an error.
# S3 is region specific (and TF S3 data source cannot specify the region).
# > Failed getting S3 bucket: BadRequest: Bad Request
#--------------------------------------------------------------------------------
data "aws_s3_bucket" upload {
  bucket = "${var.bucket}"
}

#--------------------------------------------------------------------------------
# Kinesis for data streaming
#--------------------------------------------------------------------------------
data "aws_kinesis_stream" "source" {
  name = "${var.kinesis_stream_name}"
}

#--------------------------------------------------------------------------------
# SNS
#--------------------------------------------------------------------------------
data "aws_sns_topic" "target" {
  name = "${var.sns_topic_name}"
}