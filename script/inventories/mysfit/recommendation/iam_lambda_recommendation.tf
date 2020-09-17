#--------------------------------------------------------------------------------
# Lambda IAM role
#--------------------------------------------------------------------------------
resource "aws_iam_role" "lambda_function_recommendation" {
  name               = "${var.PROJECT}_${var.ENV}_lambda_recommendation"
  description        = "Role for lambda to assume"
  assume_role_policy = data.aws_iam_policy_document.assume_lambda_service.json
}

#================================================================================
# SageMaker IAM permissions
#================================================================================
resource "aws_iam_role_policy_attachment" "allow_lambda_call_sagemaker_endpoint" {
  role       = aws_iam_role.lambda_function_recommendation.id
  policy_arn = aws_iam_policy.allow_lambda_call_sagemaker_endpoint.arn
}
#--------------------------------------------------------------------------------
# Send request to SageMaker endpoint for for a prediction
# https://docs.aws.amazon.com/sagemaker/latest/APIReference/API_runtime_InvokeEndpoint.html
#--------------------------------------------------------------------------------
resource "aws_iam_policy" "allow_lambda_call_sagemaker_endpoint" {
  name        = replace("${title(var.PROJECT)}${title(var.ENV)}AllowLambdaCallSageMakerEndpoint", "/[-_.$%^&*#@]/", "")
  description = "Allow Lambda call SageMaker InvokeEndpoint API"
  policy = data.aws_iam_policy_document.allow_lambda_call_sagemaker_endpoint.json
}
#--------------------------------------------------------------------------------
# Amazon SageMaker API Permissions: Actions, Permissions, and Resources Reference
# https://docs.aws.amazon.com/sagemaker/latest/dg/api-permissions-reference.html
#--------------------------------------------------------------------------------
data "aws_iam_policy_document" "allow_lambda_call_sagemaker_endpoint" {
  statement {
    sid    = replace("${title(var.PROJECT)}${title(var.ENV)}AllowLambdaCallSageMakerEndPoint", "/[-_.$%^&*#@]/", "")
    effect = "Allow"
    actions = [
      "sagemaker:InvokeEndpoint"
    ]

    #--------------------------------------------------------------------------------
    # Resource format:
    # arn:aws:sagemaker:region:account-id:endpoint/endpointName
    #--------------------------------------------------------------------------------
    resources = [
      # TODO: Limit to the target lambda endpoint
      "arn:aws:sagemaker:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:endpoint/${local.sagemaker_recommendation_endpoint_name}"
    ]
  }
}

#================================================================================
# X-Ray IAM Permissions
#================================================================================
resource "aws_iam_role_policy_attachment" "allow_lambda_recommendation_access_xray" {
  role       = aws_iam_role.lambda_function_recommendation.id
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}
