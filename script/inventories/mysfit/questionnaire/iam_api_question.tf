#================================================================================
# APIGW IAM permissions
#================================================================================
#--------------------------------------------------------------------------------
# Resource-Based IAM permission for API GW to invoke lambda via alias (qualifier)
# To allow an AWS service to invoke a function.
# https://docs.aws.amazon.com/lambda/latest/dg/access-control-resource-based.html
#--------------------------------------------------------------------------------
resource "aws_lambda_permission" "allow_apigw_invoke_lambda_receive_question_alias" {
  statement_id  = "${title(var.PROJECT)}${title(var.ENV)}AllowAPIGWInvokeLambdaReceiveQuestion"
  principal     = "apigateway.amazonaws.com"

  #--------------------------------------------------------------------------------
  # Principal ARN that invokes the lambda
  # Note that there is no '/' in front of ${aws_api_gateway_resource.question.path}" because it includes "/"
  #--------------------------------------------------------------------------------

  #--------------------------------------------------------------------------------
  # The source ARN format in the terraform example stopped working
  #source_arn    = "${aws_api_gateway_rest_api.mysfit.execution_arn}/*/*/*"
  #--------------------------------------------------------------------------------
  #source_arn = "arn:aws:execute-api:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.mysfit.id}/*/${aws_api_gateway_integration.question_post.integration_http_method}${aws_api_gateway_resource.question.path}"
  source_arn = "arn:aws:execute-api:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:${data.aws_api_gateway_rest_api.mysfit.id}/*/*/*"

  action        = "lambda:InvokeFunction"
  function_name = local.lambda_receive_question_function_name
  qualifier     = local.lambda_receive_question_function_alias
}
