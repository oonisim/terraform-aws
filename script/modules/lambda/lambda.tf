#================================================================================
# Lambda function transform
# [Objective]
# Acquire the Cognito token for a user credential (email/password)
#================================================================================
resource "aws_s3_bucket_object" "lambda_package" {
  #--------------------------------------------------------------------------------
  # Target S3 bucket/key
  #--------------------------------------------------------------------------------
  bucket        = data.aws_s3_bucket.this.bucket
  key           = "${var.lambda_alias_name}/${basename(var.lambda_package_path)}"
  storage_class = "STANDARD_IA"

  #--------------------------------------------------------------------------------
  # Source file/etag
  #--------------------------------------------------------------------------------
  source = var.lambda_package_path

  #--------------------------------------------------------------------------------
  # The lambda package can be created dynamically during the Terraform execution.
  # Terraform checks the file and compute its checksum at the plan phase while
  # creating DAG, hence it does not use the file that is created during terraform apply
  ## All the file (lambda package) must be ready before executing Terraform.
  # To use the file dynamically generated, use timestmp to force upload everytime.
  #
  # Or use archive_file and compute the MD5 from the file.
  #--------------------------------------------------------------------------------
  etag   = var.lambda_package_md5
  #etag = timestamp()

  #--------------------------------------------------------------------------------
  # Cannot use with etag and server_side_encryption together
  #--------------------------------------------------------------------------------
  #server_side_encryption = "AES256"
  #--------------------------------------------------------------------------------
}

#--------------------------------------------------------------------------------
# Lambda
# TODO: Firehose VPC Endpoint and Lambda in VPC as in https://docs.aws.amazon.com/firehose/latest/dev/vpc.html
#--------------------------------------------------------------------------------
resource "aws_lambda_function" "this" {
  #--------------------------------------------------------------------------------
  # To make a lambda "published" (immutable) version.
  # https://github.com/hashicorp/terraform/issues/6067
  #
  # If not published, $LATEST will be used which is mutable/transient hence inconsistent
  # Should not use $LATEST for any lambda invocation but use a specific version
  # which we know what it is.
  #--------------------------------------------------------------------------------
  publish = true

  function_name = "${var.PROJECT}_${var.ENV}_${var.lambda_function_name}"
  handler       = "${var.lambda_file_name}.${var.lambda_handler_method}"
  runtime       = var.lambda_runtime
  role          = data.aws_iam_role.this.arn

  s3_bucket = aws_s3_bucket_object.lambda_package.bucket
  s3_key    = aws_s3_bucket_object.lambda_package.key

  #--------------------------------------------------------------------------------
  # Need to detect the code change with source_code_hash.
  # https://github.com/hashicorp/terraform/issues/5150
  #
  # Need to make sure of zip with output_base64sha256 (output_sha not work)
  # https://github.com/hashicorp/terraform/issues/6513
  #--------------------------------------------------------------------------------
  # TODO: Verify the document what to use for the souce code hash
  source_code_hash = aws_s3_bucket_object.lambda_package.etag

  #--------------------------------------------------------------------------------
  # Environment
  #--------------------------------------------------------------------------------
  dynamic "environment" {
    for_each = var.lambda_environment_variables
    content {
      variables = var.lambda_environment_variables
    }
  }

  #--------------------------------------------------------------------------------
  # Lambda resource limits
  # https://docs.aws.amazon.com/lambda/latest/dg/limits.html
  #--------------------------------------------------------------------------------
  memory_size = var.lambda_memory_size
  timeout     = var.lambda_timeout

  #--------------------------------------------------------------------------------
  # VPC
  #--------------------------------------------------------------------------------
  dynamic "vpc_config" {
    for_each = var.vpc_config == null ? {} : var.vpc_config
    content {
      security_group_ids = var.vpc_config["security_group_ids"]
      subnet_ids         = var.vpc_config["subnet_ids"]
    }
  }

  #--------------------------------------------------------------------------------
  #  X-Ray
  #
  #--------------------------------------------------------------------------------
  tracing_config {
    mode = var.tracing_config_mode
  }
}

#--------------------------------------------------------------------------------
# Attach alias to the lambda function version published
# Beware that a mutable tag is NOT a good practice.
# We must always be able to identify a specific revision of the code.
#
# For instance, (not lambda but) for docker environment, LATEST alias/tag
# can point version 12 and new version is published and now LATEST points to
# version 13. A new K8S pod is launched and it will be verison 13 whereas
# still old version 12 pods have been running, causing mixed versions in the env.
#--------------------------------------------------------------------------------
resource "aws_lambda_alias" "this" {
  name             = var.lambda_alias_name
  description      = "Alias ${var.lambda_alias_name} to lambda function ${aws_lambda_function.this.function_name}"
  function_name    = aws_lambda_function.this.function_name
  function_version = aws_lambda_function.this.version
}
