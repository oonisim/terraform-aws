# TODO: Firehose VPC Endpoint and Lambda in VPC as in https://docs.aws.amazon.com/firehose/latest/dev/vpc.html
module "lambda" {
  source = "../../../modules/lambda"

  PROJECT = var.PROJECT
  ENV     = var.ENV

  #--------------------------------------------------------------------------------
  # Lambda package and the target S3 to upload it to
  #--------------------------------------------------------------------------------
  bucket_name         = local.bucket_name
  lambda_package_path = data.archive_file.lambda_package.output_path
  lambda_package_md5  = data.archive_file.lambda_package.output_md5

  iam_role_name = local.iam_role_lambda_transform

  #--------------------------------------------------------------------------------
  # Lambda function and handler to invoke
  #--------------------------------------------------------------------------------
  lambda_function_name = var.lambda_transform_function_name
  lambda_alias_name    = var.lambda_transform_alias_name

  # <filename>.<handler> for Lambda runtime to invoke the function
  lambda_file_name      = replace(basename(local_file.lambda_transform_py.filename), "/^(.*)\\..*$/", "$1")
  lambda_handler_method = var.lambda_transform_handler_method

  #--------------------------------------------------------------------------------
  # Lambda runtime configurations
  #--------------------------------------------------------------------------------
  lambda_runtime     = var.lambda_transform_runtime
  lambda_memory_size = var.lambda_transform_memory_size
  lambda_timeout     = var.lambda_transform_timeout
}
