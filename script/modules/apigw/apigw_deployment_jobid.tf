#--------------------------------------------------------------------------------
# Proxy resource method deployment
# [CORS]
# Do not forget to update aws_api_gateway_integration_response.job_options
# to allow each method GET/DELETE/PUT, etc.
#--------------------------------------------------------------------------------
resource "aws_api_gateway_method_settings" "jobid_get" {
  rest_api_id = aws_api_gateway_resource.job.rest_api_id
  stage_name  = local.api_deployment_stage_name
  method_path = "${aws_api_gateway_resource.jobid.path_part}/${aws_api_gateway_method.jobid_get.http_method}"

  settings {
    metrics_enabled = true
    logging_level   = var.apigw_deploy_lambda_jobid_get_loglevel
  }

  # To avoid conflict operation is going
  depends_on = [aws_api_gateway_method_settings.job_post]
}

resource "aws_api_gateway_method_settings" "jobid_delete" {
  rest_api_id = aws_api_gateway_resource.job.rest_api_id
  stage_name  = local.api_deployment_stage_name
  method_path = "${aws_api_gateway_resource.jobid.path_part}/${aws_api_gateway_method.jobid_delete.http_method}"

  settings {
    metrics_enabled = true
    logging_level   = var.apigw_deploy_lambda_jobid_delete_loglevel
  }

  # To avoid conflict operation is going
  depends_on = [aws_api_gateway_method_settings.jobid_get]
}

