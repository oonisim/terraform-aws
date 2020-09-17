#--------------------------------------------------------------------------------
# IAM permission for API GW to invoke lambda via alias (qualifier)
#--------------------------------------------------------------------------------
resource "aws_lambda_permission" "allow_apigw_invoke_lambda_kinesis_producer_alias" {
  statement_id  = "${var.PROJECT}_${var.ENV}_AllowAPIGatewayInvokeLambdaUploadAlias"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.kinesis_producer.arn}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_rest_api_execution_arn}/*/*/*"

  qualifier     = "${aws_lambda_alias.kinesis_producer.name}"
}
