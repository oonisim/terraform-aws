data "aws_lambda_alias" "transform" {
  name             = var.lambda_alias_name
  function_name    = var.lambda_function_name
}

data "aws_lambda_function" "transform" {
  function_name = var.lambda_function_name
  qualifier = var.lambda_alias_name
}

data "aws_s3_bucket" "bucket" {
  bucket = "${var.bucket_name}"
}
data "aws_cloudwatch_log_group" "this" {
  name = "${var.cloudwatch_loggroup_name}"
}

locals {
  bucket_arn = data.aws_s3_bucket.bucket.arn
  cloudwatch_loggroup_arn = data.aws_cloudwatch_log_group.this.arn
}