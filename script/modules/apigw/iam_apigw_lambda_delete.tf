#--------------------------------------------------------------------------------
# IAM permission for API GW to invoke lambda via alias (qualifier)
#--------------------------------------------------------------------------------
resource "aws_lambda_permission" "allow_apigw_invoke_lambda_delete_alias" {
  statement_id  = "${title(var.PROJECT)}${title(var.ENV)}AllowAPIGWInvokeLambdaDelete"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/*/*"
  action        = "lambda:InvokeFunction"
  function_name = local.lambda_delete_function_name
  qualifier     = local.lambda_delete_qualifier
}

