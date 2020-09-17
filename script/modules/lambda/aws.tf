data "aws_availability_zones" "all" {
}

data "aws_region" "current" {
}

# https://www.terraform.io/docs/providers/aws/d/caller_identity.html
data "aws_caller_identity" "current" {
}

data "aws_iam_role" "this" {
  name = var.iam_role_name
}

data "aws_s3_bucket" "this" {
  bucket = "${var.bucket_name}"
}
