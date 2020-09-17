#--------------------------------------------------------------------------------
# Deployment deliverables for the resource
#--------------------------------------------------------------------------------
locals {
  #api_gateway_signin_url = "${aws_api_gateway_deployment.this.invoke_url}${aws_api_gateway_stage.this.stage_name}${aws_api_gateway_resource.signin.path}"
  api_gateway_signin_url = "${local.api_deployment_invoke_url}${local.api_deployment_stage_name}${aws_api_gateway_resource.authping.path}"
}

#--------------------------------------------------------------------------------
# Deployment level configurations for the resource
#--------------------------------------------------------------------------------
resource "aws_api_gateway_method_settings" "signin_get" {
  rest_api_id = aws_api_gateway_resource.signin.rest_api_id
  stage_name  = local.api_deployment_stage_name
  method_path = "${aws_api_gateway_resource.signin.path_part}/${aws_api_gateway_method.signin_get.http_method}"

  settings {
    metrics_enabled = true
    logging_level   = var.apigw_deploy_signin_loglevel
  }

  # To avoid conflict operation is going
  depends_on = [aws_api_gateway_method_settings.authping]
}

resource "aws_api_gateway_method_settings" "signin_options" {
  rest_api_id = aws_api_gateway_resource.signin.rest_api_id
  stage_name  = local.api_deployment_stage_name
  method_path = "${aws_api_gateway_resource.signin.path_part}/${aws_api_gateway_method.signin_options.http_method}"

  settings {
    metrics_enabled = true
    logging_level   = var.apigw_deploy_signin_loglevel
  }

  # To avoid conflict operation is going
  depends_on = [aws_api_gateway_method_settings.signin_get]
}

