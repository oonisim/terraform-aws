#--------------------------------------------------------------------------------
# Cognito User Pool
# Required to manage the Cognito User Pool users.
#--------------------------------------------------------------------------------
output "identity_provider_name" {
  value = aws_cognito_user_pool.this.name
}

output "cognito_userpool_id" {
  value = aws_cognito_user_pool.this.id
}

output "cognito_userpool_arn" {
  value = aws_cognito_user_pool.this.arn
}

output "cognito_userpool_endpoint" {
  value = aws_cognito_user_pool.this.endpoint
}

output "cognito_userpool_client_id" {
  value = aws_cognito_user_pool_client.this.id
}

output "cognito_userpool_client_secret" {
  value = aws_cognito_user_pool_client.this.client_secret
}

output "cognito_userpool_region" {
  value = data.aws_region.current.name
}

output "cognito_userpool_region_description" {
  value = data.aws_region.current.description
}

#--------------------------------------------------------------------------------
# Lambda
#--------------------------------------------------------------------------------
output "lambda_signin_function_name" {
  value = local.lambda_signin_function_name
}

output "lambda_signin_qualifier" {
  value = local.lambda_signin_qualifier
}

