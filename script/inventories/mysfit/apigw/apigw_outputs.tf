#--------------------------------------------------------------------------------
# API
#--------------------------------------------------------------------------------
output "api_gateway_rest_api_name" {
  value = aws_api_gateway_rest_api.mysfit.name
}

output "api_gateway_rest_api_id" {
  value = aws_api_gateway_rest_api.mysfit.id
}

output "api_gateway_rest_api_root_resource_id" {
  value = aws_api_gateway_rest_api.mysfit.root_resource_id
}

output "api_gateway_rest_api_execution_arn" {
  value = aws_api_gateway_rest_api.mysfit.execution_arn
}
