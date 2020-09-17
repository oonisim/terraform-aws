#--------------------------------------------------------------------------------
# Deployment deliverables for the resource
#--------------------------------------------------------------------------------
locals {
  api_gateway_job_url = "${local.api_deployment_invoke_url}${local.api_deployment_stage_name}${aws_api_gateway_resource.job.path}"
}

resource "aws_api_gateway_method_settings" "job_get" {
  rest_api_id = aws_api_gateway_resource.job.rest_api_id
  stage_name  = local.api_deployment_stage_name
  method_path = "${aws_api_gateway_resource.job.path_part}/${aws_api_gateway_method.job_get.http_method}"

  settings {
    metrics_enabled = true
    logging_level   = var.apigw_deploy_lambda_job_get_loglevel
  }

  # To avoid conflict operation is going
  depends_on = [aws_api_gateway_method_settings.signin_options]
}

resource "aws_api_gateway_method_settings" "job_post" {
  rest_api_id = local.rest_api_id
  stage_name  = local.api_deployment_stage_name
  method_path = "${aws_api_gateway_resource.job.path_part}/${aws_api_gateway_method.job_post.http_method}"

  settings {
    metrics_enabled = true
    logging_level   = var.apigw_deploy_job_post_loglevel
  }

  # To avoid conflict operation is going
  depends_on = [aws_api_gateway_method_settings.job_get]
}

