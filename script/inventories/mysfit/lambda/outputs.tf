output "lambda_function_name" {
  value = module.lambda.lambda_function_name
}
output "lambda_function_version" {
  value = module.lambda.lambda_function_version
}
output "lambda_function_alias" {
  value = module.lambda.lambda_function_alias
}
output "lambda_function_qualified_arn" {
  value = module.lambda.lambda_function_qualified_arn
}
#--------------------------------------------------------------------------------
# Lambda alias invocation ARN.
# Invoke lambda via alias or version, NOT directly function itself as it is
# $LATEST version which is mutable.
# https://github.com/terraform-providers/terraform-provider-aws/issues/4479
#--------------------------------------------------------------------------------
output "lambda_function_invoke_arn" {
  value = module.lambda.lambda_function_invoke_arn
}
output "lambda_function_handler" {
  value = module.lambda.lambda_function_handler
}