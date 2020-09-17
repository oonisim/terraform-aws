output "lambda_function_name" {
  value = aws_lambda_function.this.function_name
}
output "lambda_function_alias" {
  value = aws_lambda_alias.this.name
}

#--------------------------------------------------------------------------------
# Lambda alias invocation ARN.
# Invoke lambda via alias, NOT directly the function itself.
# https://github.com/terraform-providers/terraform-provider-aws/issues/4479
#--------------------------------------------------------------------------------
output "lambda_function_version" {
  value = aws_lambda_function.this.version
}
output "lambda_function_qualified_arn" {
  value = aws_lambda_function.this.qualified_arn
}
output "lambda_function_invoke_arn" {
  value = aws_lambda_alias.this.invoke_arn
}
output "lambda_function_handler" {
  value = aws_lambda_function.this.handler
}
output "lambda_function_role_arn" {
  value = aws_lambda_function.this.role
}