#--------------------------------------------------------------------------------
# IAM permission for API GW to invoke lambda via alias (qualifier)
#--------------------------------------------------------------------------------
resource "aws_lambda_permission" "allow_apigw_invoke_lambda_create_alias" {
  statement_id  = "${title(var.PROJECT)}${title(var.ENV)}AllowAPIGWInvokeLambdaCreate"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/*/*"
  action        = "lambda:InvokeFunction"
  function_name = local.lambda_create_function_name
  qualifier     = local.lambda_create_qualifier
}

