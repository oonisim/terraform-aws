output "api_gateway_recommendation_path" {
  value = aws_api_gateway_resource.recommendation.path
}
output "api_gateway_recommendation_path_part" {
  value = aws_api_gateway_resource.recommendation.path_part
}
output "api_gateway_deployment_invoke_url" {
  value = local.api_gateway_deployment_invoke_url
}