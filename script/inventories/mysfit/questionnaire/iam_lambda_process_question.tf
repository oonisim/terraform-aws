#--------------------------------------------------------------------------------
# Lambda IAM role
#--------------------------------------------------------------------------------
resource "aws_iam_role" "lambda_function_process_question" {
  name               = "${var.PROJECT}_${var.ENV}_lambda_process_question"
  description        = "Role for lambda to assume"
  assume_role_policy = data.aws_iam_policy_document.assume_lambda_service.json
}

#================================================================================
# DynamoDB Stream IAM permissions
#================================================================================
resource "aws_iam_role_policy_attachment" "allow_lambda_process_question_access_dynamodb_stream" {
  role       = aws_iam_role.lambda_function_process_question.id
  policy_arn = aws_iam_policy.allow_lambda_process_question_access_dynamodb_stream.arn
}
resource "aws_iam_policy" "allow_lambda_process_question_access_dynamodb_stream" {
  name        = replace("${title(var.PROJECT)}${title(var.ENV)}AllowLambdaProcessQuestionCallDynamoDBStreamEndpoint", "/[-_.$%^&*#@]/", "")
  description = "Allow Lambda access DynamoDB Stream Endpoint API"
  policy = data.aws_iam_policy_document.allow_lambda_process_question_access_dynamodb_stream.json
}
#--------------------------------------------------------------------------------
# Using AWS Lambda with Amazon DynamoDB
# https://docs.aws.amazon.com/lambda/latest/dg/with-ddb.html#events-dynamodb-permissions
#--------------------------------------------------------------------------------
data "aws_iam_policy_document" "allow_lambda_process_question_access_dynamodb_stream" {
  statement {
    sid    = replace("${title(var.PROJECT)}${title(var.ENV)}AllowLambdaProcessQuestionCallDynamoDBStreamEndpoint", "/[-_.$%^&*#@]/", "")
    effect = "Allow"
    actions = [
      "dynamodb:DescribeStream",
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator",
      "dynamodb:ListStreams"
    ]
    resources = [
      #--------------------------------------------------------------------------------
      # Every stream is uniquely identified by an Amazon Resource Name (ARN).
      # https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Streams.html#Streams.Enabling
      #--------------------------------------------------------------------------------
      "arn:aws:dynamodb:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:table/${var.dynamodb_table_name}/stream/*"
    ]
  }
}

#================================================================================
# SNS IAM permissions
#================================================================================
resource "aws_iam_role_policy_attachment" "allow_lambda_process_question_access_sns" {
  role       = aws_iam_role.lambda_function_process_question.id
  policy_arn = aws_iam_policy.allow_lambda_process_question_access_sns.arn
}
resource "aws_iam_policy" "allow_lambda_process_question_access_sns" {
  name        = replace("${title(var.PROJECT)}${title(var.ENV)}AllowLambdaProcessQuestionCallSNS", "/[-_.$%^&*#@]/", "")
  description = "Allow Lambda access SNS"
  policy = data.aws_iam_policy_document.allow_lambda_process_question_access_sns.json
}
data "aws_iam_policy_document" "allow_lambda_process_question_access_sns" {
  statement {
    sid    = replace("${title(var.PROJECT)}${title(var.ENV)}AllowLambdaProcessQuestionCallSNS", "/[-_.$%^&*#@]/", "")
    effect = "Allow"
    actions = [
      "sns:Publish"
    ]
    resources = [
      local.sns_topic_arn
    ]
  }
}

#================================================================================
# X-Ray IAM Permissions
#================================================================================
resource "aws_iam_role_policy_attachment" "allow_lambda_process_question_access_xray" {
  role       = aws_iam_role.lambda_function_process_question.id
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}