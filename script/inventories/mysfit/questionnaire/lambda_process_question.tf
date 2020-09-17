locals {
  lambda_process_question_environment_variables = {
    SNS_TOPIC_ARN = module.sns.sns_topic_arn
  }
}
module "lambda_process_question" {
  source = "../../../modules/lambda"

  PROJECT = var.PROJECT
  ENV     = var.ENV

  #--------------------------------------------------------------------------------
  # Lambda package and the target S3 to upload it to
  #--------------------------------------------------------------------------------
  bucket_name         = local.bucket_name
  lambda_package_path = data.archive_file.lambda_process_question_package.output_path
  lambda_package_md5  = data.archive_file.lambda_process_question_package.output_md5

  iam_role_name = aws_iam_role.lambda_function_process_question.name

  #--------------------------------------------------------------------------------
  # Lambda function
  #--------------------------------------------------------------------------------
  lambda_function_name = var.lambda_process_question_function_name
  lambda_alias_name    = var.lambda_process_question_alias_name

  #--------------------------------------------------------------------------------
  # Lambda handler
  # <filename>.<handler> for Lambda runtime to invoke the function
  # Remove file extention (.py, .js, etc)
  #--------------------------------------------------------------------------------
  lambda_file_name      = replace(basename(local.process_question_file_path), "/^(.*)\\..*$/", "$1")
  lambda_handler_method = var.lambda_process_question_handler_method

  #--------------------------------------------------------------------------------
  # Lambda runtime configurations
  #--------------------------------------------------------------------------------
  lambda_runtime               = var.lambda_process_question_runtime
  lambda_memory_size           = var.lambda_process_question_memory_size
  lambda_timeout               = var.lambda_process_question_timeout
  lambda_environment_variables = local.lambda_process_question_environment_variables

  #--------------------------------------------------------------------------------
  # X-Ray
  #--------------------------------------------------------------------------------
  tracing_config_mode = "Active"
}

# Expose I/F
locals {
  lambda_process_question_qualified_arn    = module.lambda_process_question.lambda_function_qualified_arn
  lambda_process_question_invoke_arn       = module.lambda_process_question.lambda_function_invoke_arn
  lambda_process_question_function_name    = module.lambda_process_question.lambda_function_name
  lambda_process_question_function_version = module.lambda_process_question.lambda_function_version
  lambda_process_question_function_alias   = module.lambda_process_question.lambda_function_alias
  lambda_process_question_function_handler = module.lambda_process_question.lambda_function_handler
  lambda_process_question_iam_role_arn     = module.lambda_process_question.lambda_function_role_arn
}