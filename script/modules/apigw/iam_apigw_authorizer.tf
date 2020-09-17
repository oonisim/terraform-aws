#--------------------------------------------------------------------------------
# IAM Role for API Gateway to assume to invoke Authorizers.
#--------------------------------------------------------------------------------
resource "aws_iam_role" "api_gateway_auth_invocation" {
  name               = "${var.PROJECT}_${var.ENV}_apigw_auth_invocation"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_apigateway_service.json
}

#--------------------------------------------------------------------------------
# IAM policy for for API GW to invoke lambda authorizer and its aliases.
#--------------------------------------------------------------------------------
data "aws_iam_policy_document" "invoke_lambda_authorizer" {
  statement {
    sid    = "${title(var.PROJECT)}${title(var.ENV)}AllowAPIInvokeLambda"
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
    ]
    resources = [
      "*",
    ]
    #"${aws_lambda_function.authorizer.arn}",
    #"${aws_lambda_function.authorizer.arn}:*",
  }
}

resource "aws_iam_role_policy" "invoke_lambda_authorizer" {
  name   = "${var.PROJECT}_${var.ENV}_allow_apigw_invoke_authorizer"
  role   = aws_iam_role.api_gateway_auth_invocation.id
  policy = data.aws_iam_policy_document.invoke_lambda_authorizer.json
}

