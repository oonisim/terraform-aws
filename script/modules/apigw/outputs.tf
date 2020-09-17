#--------------------------------------------------------------------------------
# API
#--------------------------------------------------------------------------------
output "api_gateway_rest_api_name" {
  value = aws_api_gateway_rest_api.this.name
}

output "api_gateway_rest_api_id" {
  value = aws_api_gateway_rest_api.this.id
}

output "api_gateway_rest_api_root_resource_id" {
  value = aws_api_gateway_rest_api.this.root_resource_id
}

output "api_gateway_rest_api_execution_arn" {
  value = aws_api_gateway_rest_api.this.execution_arn
}

output "api_gateway_rest_api_root_path" {
  value = aws_api_gateway_resource.root.path
}

output "api_gateway_rest_api_current_path" {
  value = aws_api_gateway_resource.current.path
}

output "api_gateway_deployment_id" {
  value = aws_api_gateway_deployment.this.id
}

output "api_gateway_deployment_rest_api_id" {
  value = aws_api_gateway_deployment.this.rest_api_id
}

output "api_gateway_deployment_rest_api_invoke_url" {
  value = aws_api_gateway_deployment.this.invoke_url
}

output "api_gateway_deployment_stage_name" {
  #value = "${aws_api_gateway_deployment.this.stage_name}"
  value = aws_api_gateway_stage.this.stage_name
}

#--------------------------------------------------------------------------------
# API Gateway Authorizer ID
# Required for API method requests to setup their authorizers.
#--------------------------------------------------------------------------------
output "api_gateway_authorizer_id" {
  value = local.api_authorizer_id
}

#--------------------------------------------------------------------------------
# API Gateway and authorizer testing URLs
#--------------------------------------------------------------------------------
# URL to ping the API gateway to test its availability.
output "api_gateway_ping_url" {
  value = local.api_gateway_ping_url
}

output "api_gateway_authping_url" {
  value = local.api_gateway_authping_url
}

output "api_gateway_signin_url" {
  value = local.api_gateway_signin_url
}

output "api_gateway_job_url" {
  value = local.api_gateway_job_url
}

