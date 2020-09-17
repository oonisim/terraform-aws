#--------------------------------------------------------------------------------
# Deployment deliverables for the resource
#--------------------------------------------------------------------------------
locals {
  #api_gateway_ping_url = "${aws_api_gateway_deployment.this.invoke_url}${aws_api_gateway_stage.this.stage_name}${aws_api_gateway_resource.ping.path}"
  api_gateway_ping_url = "${local.api_deployment_invoke_url}${local.api_deployment_stage_name}${aws_api_gateway_resource.ping.path}"
}

#--------------------------------------------------------------------------------
# Deployment level configurations for the resource
#--------------------------------------------------------------------------------
resource "aws_api_gateway_method_settings" "ping" {
  rest_api_id = aws_api_gateway_resource.ping.rest_api_id
  stage_name  = local.api_deployment_stage_name
  method_path = "${aws_api_gateway_resource.ping.path_part}/${aws_api_gateway_method.ping_get.http_method}"

  settings {
    metrics_enabled = true
    logging_level   = var.apigw_deploy_ping_loglevel
  }
}

