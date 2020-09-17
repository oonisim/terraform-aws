#--------------------------------------------------------------------------------
# Deployment deliverables for the resource
#--------------------------------------------------------------------------------

locals {
  api_gateway_authping_url = "${local.api_deployment_invoke_url}${local.api_deployment_stage_name}${aws_api_gateway_resource.authping.path}"
}

resource "aws_api_gateway_method_settings" "authping" {
  rest_api_id = aws_api_gateway_resource.authping.rest_api_id
  stage_name  = local.api_deployment_stage_name
  method_path = "${aws_api_gateway_resource.authping.path_part}/${aws_api_gateway_method.authping_get.http_method}"

  settings {
    metrics_enabled = true
    logging_level   = var.apigw_deploy_authping_loglevel
  }

  # To avoid conflict operation is going
  depends_on = [aws_api_gateway_method_settings.ping]
}

