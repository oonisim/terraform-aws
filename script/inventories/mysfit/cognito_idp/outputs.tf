#--------------------------------------------------------------------------------
# Cognito User Pool
# Required to manage the Cognito User Pool users.
#--------------------------------------------------------------------------------
output "identity_provider_name" {
  value = module.identity.identity_provider_name
}

output "cognito_userpool_id" {
  value = module.identity.cognito_userpool_id
}

output "cognito_userpool_arn" {
  value = module.identity.cognito_userpool_arn
}

output "cognito_userpool_endpoint" {
  value = module.identity.cognito_userpool_endpoint
}

output "cognito_userpool_client_id" {
  value = module.identity.cognito_userpool_client_id
}

output "cognito_userpool_client_secret" {
  value = module.identity.cognito_userpool_client_secret
}

output "cognito_userpool_region" {
  value = module.identity.cognito_userpool_region
}

output "cognito_userpool_region_description" {
  value = module.identity.cognito_userpool_region_description
}

#--------------------------------------------------------------------------------
# Lambda
#--------------------------------------------------------------------------------
output "lambda_signin_function_name" {
  value = module.identity.lambda_signin_function_name
}

output "lambda_signin_qualifier" {
  value = module.identity.lambda_signin_qualifier
}

