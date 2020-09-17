#--------------------------------------------------------------------------------
# IAM permission for API GW to invoke lambda
#--------------------------------------------------------------------------------
resource "aws_lambda_permission" "allow_apigw_invoke_lambda_signin_alias" {
  statement_id  = "${title(var.PROJECT)}${title(var.ENV)}AllowAPIGWInvokeLambdaSignin"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/*/*"
  action        = "lambda:InvokeFunction"
  function_name = local.lambda_signin_function_name
  qualifier     = local.lambda_signin_qualifier
}

