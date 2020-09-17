output "api_gateway_question_path" {
  value = aws_api_gateway_resource.question.path
}
output "api_gateway_question_path_part" {
  value = aws_api_gateway_resource.question.path_part
}
output "api_gateway_deployment_invoke_url" {
  value = local.api_gateway_deployment_invoke_url
}