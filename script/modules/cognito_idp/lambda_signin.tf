#================================================================================
# Lambda function signin
# [Objective]
# Acquire the Cognito token for a user credential (email/password)
#================================================================================

#--------------------------------------------------------------------------------
# See https://github.com/hashicorp/terraform/issues/20064
#--------------------------------------------------------------------------------
locals {
  lambda_signin_trigger = "${local.module_path}/${var.lambda_signin_trigger}"
  lambda_signin_dir     = "${local.module_path}/${var.lambda_signin_dir}"
  signin_archive_dir    = "${local.module_path}/${var.lambda_signin_archive_dir}"
  signin_archive_path   = "${local.signin_archive_dir}/${var.lambda_signin_archive}"
  template_path         = "${local.lambda_signin_dir}/${var.lambda_signin_template}"
}
#--------------------------------------------------------------------------------


#--------------------------------------------------------------------------------
# Load the template file for lambda.
# Data sources get executed at the beginning of DAG. Resouces cannot depend on them.
# [Note]
# The dependency must be injected, not be reference to eliminate hidden dependency
# embedded/hard-coded in the service consumer side.
#--------------------------------------------------------------------------------
data "template_file" "lambda_signin" {
  template = "${file(local.template_path)}"
  vars = {
    userpool_id                = aws_cognito_user_pool.this.id
    userpool_app_client_id     = aws_cognito_user_pool_client.this.id
    userpool_app_client_secret = aws_cognito_user_pool_client.this.client_secret
    userpool_region            = var.REGION
  }
}

#--------------------------------------------------------------------------------
# Templating - Lambda Function
# sign-in lambda function file is created from the identity_${provider}.py.template
#--------------------------------------------------------------------------------
resource "local_file" "lambda_signin_py" {
  content  = data.template_file.lambda_signin.rendered
  filename = "${local.lambda_signin_dir}/${var.lambda_signin_file}"
}

resource "null_resource" "build_lambda_signin_package" {
  provisioner "local-exec" {
    command = <<EOF
      ${local.lambda_signin_dir}/setup.sh
EOF
  }
  provisioner "local-exec" {
    command = <<EOF
      chmod    ugo+rx ${local.lambda_signin_dir}
      chmod -R ugo+r  ${local.lambda_signin_dir}/*
EOF

  }
  provisioner "local-exec" {
    #--------------------------------------------------------------------------------
    # [Note]
    # Files in the zip file MUST be readable by anyone to be exectued as lambda.
    # To force re-uplaod, change the content of the trigger file.
    #--------------------------------------------------------------------------------
    command = <<EOF
      zip -vr "${local.signin_archive_path}" *  -x \"*.template\"
EOF

    working_dir = local.lambda_signin_dir
  }

  #--------------------------------------------------------------------------------
  # Regenerate lambda function package upon the change of the files.
  #--------------------------------------------------------------------------------
  triggers = {
    lambda  = md5(local_file.lambda_signin_py.content)
    trigger = filemd5(local.lambda_signin_trigger)
    archive = filemd5(local.signin_archive_path)
  }
}

resource "aws_s3_bucket_object" "lambda_signin_package" {
  #--------------------------------------------------------------------------------
  # Source file/etag
  #--------------------------------------------------------------------------------
  source = local.signin_archive_path

  #--------------------------------------------------------------------------------
  # Force re-signin. The MD5 is calcuated at the resouce evaluation, which is
  # BEFORE the recreation of the package file. Hence MD5 will not change.
  #--------------------------------------------------------------------------------
  #etag          = filebase64sha256(local.signin_archive_path)
  etag = timestamp()

  #--------------------------------------------------------------------------------

  #--------------------------------------------------------------------------------
  # Target S3 bucket/key
  #--------------------------------------------------------------------------------
  bucket = data.aws_s3_bucket.project.bucket
  key    = var.lambda_signin_archive

  #storage_class= "GLACIER
  storage_class = "STANDARD_IA"

  #--------------------------------------------------------------------------------
  # Cannot use with etag and server_side_encryption together
  #--------------------------------------------------------------------------------
  #server_side_encryption = "AES256"
  #--------------------------------------------------------------------------------

  #--------------------------------------------------------------------------------
  # etag fails if there is no target object to signin exists for the first time.
  # Create a dummpy/empty object.
  #
  # To force re-uplaod, change the content of the trigger file.
  #--------------------------------------------------------------------------------
  depends_on = [
    null_resource.build_lambda_signin_package
  ]
}

#--------------------------------------------------------------------------------
# Lambda
#--------------------------------------------------------------------------------
#--------------------------------------------------------------------------------
# The mandatory role and policy for lambda is in the tf file of the lambda
#--------------------------------------------------------------------------------
resource "aws_iam_role" "lambda_signin" {
  name               = replace("${var.PROJECT}_${var.ENV}_lambda_signin", "/[_.@~*&%= ]/", "")
  description        = "Role for lambda to assume"
  assume_role_policy = data.aws_iam_policy_document.assume_lambda_service.json
}

resource "aws_lambda_function" "signin" {
  function_name = var.lambda_signin_name

  #--------------------------------------------------------------------------------
  # To avoid "Error creating Lambda function: timeout while waiting for state to become 'success' (timeout: 1m0s)"
  # https://forums.developer.amazon.com/questions/31047/lambda-function-timeout.html
  #--------------------------------------------------------------------------------
  s3_bucket = data.aws_s3_bucket.project.bucket
  s3_key    = aws_s3_bucket_object.lambda_signin_package.key

  #--------------------------------------------------------------------------------

  #--------------------------------------------------------------------------------
  # Need to detect the code change with source_code_hash.
  # https://github.com/hashicorp/terraform/issues/5150
  #
  # Need to make sure of zip with output_base64sha256 (output_sha not work)
  # https://github.com/hashicorp/terraform/issues/6513
  #--------------------------------------------------------------------------------
  #source_code_hash = filebase64sha256(local.signin_archive_path)
  source_code_hash = md5(local_file.lambda_signin_py.content)
  role             = aws_iam_role.lambda_signin.arn
  handler          = var.lambda_signin_handler
  runtime          = var.lambda_signin_runtime

  #--------------------------------------------------------------------------------
  # Lambda resource limits
  # https://docs.aws.amazon.com/lambda/latest/dg/limits.html
  #--------------------------------------------------------------------------------
  memory_size = var.lambda_signin_memory_size
  timeout     = var.lambda_signin_timeout

  depends_on = [aws_s3_bucket_object.lambda_signin_package]
}

resource "aws_lambda_alias" "signin" {
  name             = "latest"
  description      = "Alias to lambda_signin"
  function_name    = aws_lambda_function.signin.arn
  function_version = var.lambda_signin_function_version
}

data "aws_lambda_function" "signin" {
  function_name = aws_lambda_alias.signin.function_name
  qualifier     = aws_lambda_alias.signin.name
}

#--------------------------------------------------------------------------------
# Lambda alias invocation ARN.
# Invoke lambda via alias, NOT directly the function itself.
# https://github.com/terraform-providers/terraform-provider-aws/issues/4479
#--------------------------------------------------------------------------------
locals {
  lambda_signin_function_name = data.aws_lambda_function.signin.function_name
  lambda_signin_qualifier     = data.aws_lambda_function.signin.qualifier
  lambda_signin_invoke_arn    = data.aws_lambda_function.signin.invoke_arn
}

