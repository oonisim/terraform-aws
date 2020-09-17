output "api_gateway_click_path" {
  value = aws_api_gateway_resource.click.path
}
output "api_gateway_click_path_part" {
  value = aws_api_gateway_resource.click.path_part
}
output "api_gateway_deployment_invoke_url" {
  value = local.api_gateway_deployment_invoke_url
}