#================================================================================
# [Objective]
# Setup S3 bucket for terraform remote state.
# 
# [Requirements]
# Each project environment has its own backend storage to isolate environments.
#
# [Variables]
# https://www.terraform.io/intro/getting-started/variables.html
# Define Terraform variable file and specify with -var-file="<file>.tfvars"
#================================================================================

#--------------------------------------------------------------------------------
# AWS Provider
# Use AWS_DEFAULT_REGION environment variable.
#--------------------------------------------------------------------------------
provider "aws" {
#  region = var.REGION
}

#--------------------------------------------------------------------------------
# S3 
# [S3 encyption]
# https://docs.aws.amazon.com/AmazonS3/latest/user-guide/default-bucket-encryption.html
# https://www.terraform.io/docs/providers/aws/r/s3_bucket.html#enable-default-server-side-encryption
#--------------------------------------------------------------------------------
resource "aws_s3_bucket" "s3_bucket_tfstate" {
  bucket        = "${var.PREFIX}-${var.PROJECT}-${var.ENV}"
  force_destroy = true
  acl           = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }  
  versioning {
    enabled = true
  }
  lifecycle {
    # Change to false if destruction of the resource is required and run destroy.
    prevent_destroy = false
  }
  tags = {
    Project     = "${var.PROJECT}"
    Environment = "${var.ENV}"
    Name        = "s3_bucket_tfstate"
    Description = "Terraform backend remote state S3"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = "${aws_s3_bucket.s3_bucket_tfstate.id}"

  block_public_acls   = true
  block_public_policy = true
}

output "s3_bucket_id" {
  value = "${aws_s3_bucket.s3_bucket_tfstate.id}"
}
output "s3_bucket_arn" {
  value = "${aws_s3_bucket.s3_bucket_tfstate.arn}"
}
