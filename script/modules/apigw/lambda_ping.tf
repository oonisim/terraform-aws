#--------------------------------------------------------------------------------
# Lambda archive to upload
#--------------------------------------------------------------------------------
data "archive_file" "lambda_ping" {
  type        = "zip"
  output_path = "${path.module}/${var.lambda_ping_archive}"
  source_file = "${path.module}/${var.lambda_ping_dir}/${var.lambda_ping_file}"
}

#--------------------------------------------------------------------------------
# The mandatory role and policy for lambda is in the tf file of the lambda
#--------------------------------------------------------------------------------
resource "aws_iam_role" "lambda_ping" {
  name               = "${var.PROJECT}_${var.ENV}_lambda_ping"
  description        = "Role for lambda to assume"
  assume_role_policy = data.aws_iam_policy_document.assume_lambda_service.json
}

#--------------------------------------------------------------------------------
# Lambda
#--------------------------------------------------------------------------------

resource "aws_lambda_function" "ping" {
  function_name = var.lambda_ping_name
  filename      = data.archive_file.lambda_ping.output_path

  #--------------------------------------------------------------------------------
  # Need to detect the code change with source_code_hash.
  # https://github.com/hashicorp/terraform/issues/5150
  #
  # Need to make sure of zip with output_base64sha256 (output_sha not work)
  # https://github.com/hashicorp/terraform/issues/6513
  #--------------------------------------------------------------------------------
  #source_code_hash = "${data.archive_file.lambda_ping.output_sha}"
  source_code_hash = data.archive_file.lambda_ping.output_base64sha256

  role    = aws_iam_role.lambda_ping.arn
  handler = var.lambda_ping_handler
  runtime = var.lambda_ping_runtime
}

resource "aws_lambda_alias" "ping" {
  name        = var.lambda_ping_qualifier
  description = "Alias to lambda_ping"

  # Use aws_lambda_function.ping to establish dependency.
  function_name    = aws_lambda_function.ping.function_name
  function_version = "$LATEST"
}

data "aws_lambda_function" "ping" {
  # Use aws_lambda_alias.ping to establish dependency.
  function_name = aws_lambda_alias.ping.function_name
  qualifier     = aws_lambda_alias.ping.name
}

#--------------------------------------------------------------------------------
# Lambda alias invocation ARN.
# Invoke lambda via alias, NOT directly the function itself.
# https://github.com/terraform-providers/terraform-provider-aws/issues/4479
#--------------------------------------------------------------------------------
locals {
  #lambda_ping_invoke_arn = "${aws_lambda_function.ping.invoke_arn}"
  #lambda_ping_invoke_arn = "${replace(aws_lambda_function.ping.invoke_arn, "${var.lambda_ping_name}", "${var.lambda_ping_name}:${var.lambda_ping_qualifier}")}"
  lambda_ping_invoke_arn = data.aws_lambda_function.ping.invoke_arn
}

