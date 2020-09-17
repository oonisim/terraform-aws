#--------------------------------------------------------------------------------
# Deployment deliverables for the resource
#--------------------------------------------------------------------------------
locals {
  api_gateway_kinesis_producer_url = "${var.api_gateway_deployment_rest_api_invoke_url}/${aws_api_gateway_resource.lambda_kinesis_producer.path_part}"
}

resource "aws_api_gateway_method_settings" "lambda_kinesis_producer" {
  rest_api_id = "${data.aws_api_gateway_rest_api.that.id}"
  stage_name  = "${var.api_gateway_deployment_stage_name}"
  method_path = "${aws_api_gateway_resource.lambda_kinesis_producer.path_part}/${aws_api_gateway_method.lambda_kinesis_producer_post.http_method}"

  settings {
    metrics_enabled = true
    logging_level   = "${var.apigw_deploy_lambda_kinesis_producer_loglevel}"
  }
}
