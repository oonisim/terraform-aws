#--------------------------------------------------------------------------------
# Lambda IAM role
#--------------------------------------------------------------------------------
resource "aws_iam_role" "lambda_function_receive_question" {
  name               = "${var.PROJECT}_${var.ENV}_lambda_receive_question"
  description        = "Role for lambda to assume"
  assume_role_policy = data.aws_iam_policy_document.assume_lambda_service.json
}

#================================================================================
# DynamoDB Stream IAM permissions
#================================================================================
resource "aws_iam_role_policy_attachment" "allow_lambda_receive_question_access_dynamodb_stream" {
  role       = aws_iam_role.lambda_function_receive_question.id
  policy_arn = aws_iam_policy.allow_lambda_receive_question_access_dynamodb_stream.arn
}
resource "aws_iam_policy" "allow_lambda_receive_question_access_dynamodb_stream" {
  name        = replace("${title(var.PROJECT)}${title(var.ENV)}AllowLambdaReceiveQuestionAccessDynamoDBTable", "/[-_.$%^&*#@]/", "")
  description = "Allow Lambda access DynamoDB Stream Endpoint API"
  policy = data.aws_iam_policy_document.allow_lambda_receive_question_access_dynamodb_stream.json
}
#--------------------------------------------------------------------------------
# Using AWS Lambda with Amazon DynamoDB
# https://docs.aws.amazon.com/lambda/latest/dg/with-ddb.html#events-dynamodb-permissions
#--------------------------------------------------------------------------------
data "aws_iam_policy_document" "allow_lambda_receive_question_access_dynamodb_stream" {
  statement {
    sid    = replace("${title(var.PROJECT)}${title(var.ENV)}AllowLambdaReceiveQuestionAccessDynamoDBTable", "/[-_.$%^&*#@]/", "")
    effect = "Allow"
    actions = [
      "dynamodb:PutItem"
    ]
    resources = [
      local.dynamodb_table_questionnaire_arn
    ]
  }
}

#================================================================================
# X-Ray IAM Permissions
#================================================================================
resource "aws_iam_role_policy_attachment" "allow_lambda_receive_question_access_xray" {
  role       = aws_iam_role.lambda_function_receive_question.id
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}