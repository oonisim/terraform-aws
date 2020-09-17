#--------------------------------------------------------------------------------
# IAM permission for API GW to invoke lambda
#--------------------------------------------------------------------------------
resource "aws_lambda_permission" "allow_apigw_invoke_lambda_ping" {
  statement_id  = "${title(var.PROJECT)}${title(var.ENV)}AllowAPIGatewayInvokeLambdaPing"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ping.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/*/*"
}

#--------------------------------------------------------------------------------
# IAM permission for API GW to invoke lambda via alias (qualifier)
#--------------------------------------------------------------------------------
resource "aws_lambda_permission" "allow_apigw_invoke_lambda_ping_alias" {
  statement_id  = "${title(var.PROJECT)}${title(var.ENV)}AllowAPIGatewayInvokeLambdaPingAlias"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ping.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/*/*"

  qualifier = aws_lambda_alias.ping.name
}

