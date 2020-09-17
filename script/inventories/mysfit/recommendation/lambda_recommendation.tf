# TODO: SageMaker VPC endpoint and lambda in VPC.
# https://docs.aws.amazon.com/sagemaker/latest/dg/interface-vpc-endpoint.html
module "lambda_recommendation" {
  source = "../../../modules/lambda"

  PROJECT = var.PROJECT
  ENV     = var.ENV

  #--------------------------------------------------------------------------------
  # Lambda package and the target S3 to upload it to
  #--------------------------------------------------------------------------------
  bucket_name         = local.bucket_name
  lambda_package_path = data.archive_file.lambda_package.output_path
  lambda_package_md5  = data.archive_file.lambda_package.output_md5

  iam_role_name = aws_iam_role.lambda_function_recommendation.name

  #--------------------------------------------------------------------------------
  # Lambda function
  #--------------------------------------------------------------------------------
  lambda_function_name = var.lambda_recommendation_function_name
  lambda_alias_name    = var.lambda_recommendation_alias_name

  #--------------------------------------------------------------------------------
  # Lambda handler
  # <filename>.<handler> for Lambda runtime to invoke the function
  # Remove file extention (.py, .js, etc)
  #--------------------------------------------------------------------------------
  lambda_file_name      = replace(basename(local_file.lambda_recommendation_py.filename), "/^(.*)\\..*$/", "$1")
  lambda_handler_method = var.lambda_recommendation_handler_method

  #--------------------------------------------------------------------------------
  # Lambda runtime configurations
  #--------------------------------------------------------------------------------
  lambda_runtime     = var.lambda_recommendation_runtime
  lambda_memory_size = var.lambda_recommendation_memory_size
  lambda_timeout     = var.lambda_recommendation_timeout
}

locals {
  lambda_recommendation_qualified_arn    = module.lambda_recommendation.lambda_function_qualified_arn
  lambda_recommendation_invoke_arn       = module.lambda_recommendation.lambda_function_invoke_arn
  lambda_recommendation_function_name    = module.lambda_recommendation.lambda_function_name
  lambda_recommendation_function_version = module.lambda_recommendation.lambda_function_version
  lambda_recommendation_function_alias   = module.lambda_recommendation.lambda_function_alias
  lambda_recommendation_function_handler = module.lambda_recommendation.lambda_function_handler
}