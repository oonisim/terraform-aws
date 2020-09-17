#--------------------------------------------------------------------------------
# IAM managed policy to access Cognito as a power user.
#--------------------------------------------------------------------------------
data "aws_iam_policy" "access_cognito" {
  arn = "arn:aws:iam::aws:policy/AmazonCognitoPowerUser"
}
resource "aws_iam_role_policy_attachment" "access_cognito" {
  role       = "${aws_iam_role.lambda_kinesis_consumer.id}"
  policy_arn = "${data.aws_iam_policy.access_cognito.arn}"
}
#--------------------------------------------------------------------------------
# IAM policy for lambda to log into cloudwatch
#--------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "execute_lambda_kinesis_consumer" {
  role       = "${aws_iam_role.lambda_kinesis_consumer.id}"
  policy_arn = "${data.aws_iam_policy.enable_lambda_logging.arn}"
}
#--------------------------------------------------------------------------------
# IAM policy to assume access S3.
#--------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "lambda_kinesis_consumer_access_s3" {
  role       = "${aws_iam_role.lambda_kinesis_consumer.id}"
  policy_arn = "${aws_iam_policy.lambda_kinesis_consumer_access_s3.arn}"
}
resource "aws_iam_policy" "lambda_kinesis_consumer_access_s3" {
  name_prefix = "${title(var.PROJECT)}${title(var.ENV)}_Allow${title(aws_lambda_function.kinesis_consumer.function_name)}AccessS3"
  policy = "${data.aws_iam_policy_document.lambda_kinesis_consumer_access_s3.json}"
}
data "aws_iam_policy_document" "lambda_kinesis_consumer_access_s3" {
  statement {
    sid    = "S3"
    effect = "Allow"
    actions = ["s3:*"]
    resources = [
      "${data.aws_s3_bucket.upload.arn}",
      "${data.aws_s3_bucket.upload.arn}/*"
    ]
  }
}
#--------------------------------------------------------------------------------
# IAM policy to assume access Kinesis.
# https://aws.amazon.com/blogs/security/how-to-create-an-aws-iam-policy-to-grant-aws-lambda-access-to-an-amazon-dynamodb-table/
# https://www.olicole.net/blog/2017/07/terraforming-aws-a-serverless-website-backend-part-1/
#--------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "allow_lambda_access_kinesis" {
  role       = "${aws_iam_role.lambda_kinesis_consumer.id}"
  policy_arn = "${aws_iam_policy.allow_lambda_access_kinesis.arn}"
}
resource "aws_iam_policy" "allow_lambda_access_kinesis" {
  name_prefix = "${title(var.PROJECT)}${title(var.ENV)}_Allow${title(aws_lambda_function.kinesis_consumer.function_name)}AccessDynamoDB"
  policy = "${data.aws_iam_policy_document.allow_lambda_access_kinesis.json}"
}
data "aws_iam_policy_document" "allow_lambda_access_kinesis" {
  # https://docs.aws.amazon.com/lambda/latest/dg/with-kinesis.html#events-kinesis-permissions
  statement {
    sid    = "Kinesis"
    effect = "Allow"
    actions = [
      "kinesis:DescribeStream",
      "kinesis:DescribeStreamSummary",
      "kinesis:GetRecords",
      "kinesis:GetShardIterator",
      "kinesis:ListShards",
      "kinesis:ListStreams",
      "kinesis:SubscribeToShard",
    ]
    resources = [
      "${data.aws_kinesis_stream.source.arn}",
    ]
  }
}

/*
resource "aws_iam_role_policy_attachment" "terraform_lambda_iam_policy_basic_execution" {
  role = "${aws_iam_role.lambda_kinesis_consumer.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "terraform_lambda_iam_policy_kinesis_execution" {
  role = "${aws_iam_role.lambda_kinesis_consumer.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaKinesisExecutionRole"
}
*/

#--------------------------------------------------------------------------------
# Allows Lambda functions to get events from Kinesis, DynamoDB and SQS
# https://docs.aws.amazon.com/lambda/latest/dg/with-kinesis.html#services-kinesis-eventsourcemapping
#--------------------------------------------------------------------------------
resource "aws_lambda_event_source_mapping" "kinesis_consumer" {
  event_source_arn  = "${data.aws_kinesis_stream.source.arn}"
  function_name     = "${aws_lambda_function.kinesis_consumer.arn}"
  starting_position = "TRIM_HORIZON"
}

resource "aws_lambda_permission" "allow_kinesis_call_kinesis_consumer" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.kinesis_consumer.arn}"
  principal     = "kinesis.amazonaws.com"
  source_arn    = "${data.aws_kinesis_stream.source.arn}",
}

#--------------------------------------------------------------------------------
# IAM policy to assume access SNS.
# https://aws.amazon.com/blogs/security/how-to-create-an-aws-iam-policy-to-grant-aws-lambda-access-to-an-amazon-dynamodb-table/
# https://www.olicole.net/blog/2017/07/terraforming-aws-a-serverless-website-backend-part-1/
#--------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "allow_lambda_access_sns" {
  role       = "${aws_iam_role.lambda_kinesis_consumer.id}"
  policy_arn = "${aws_iam_policy.allow_lambda_access_sns.arn}"
}
resource "aws_iam_policy" "allow_lambda_access_sns" {
  name_prefix = "${title(var.PROJECT)}${title(var.ENV)}_Allow${title(aws_lambda_function.kinesis_consumer.function_name)}_access_dynamo"
  policy = "${data.aws_iam_policy_document.allow_lambda_access_sns.json}"
}
data "aws_iam_policy_document" "allow_lambda_access_sns" {
  statement {
    sid    = "SNS"
    effect = "Allow"
    actions = [
      "sns:publish"
    ]
    resources = [
      "${data.aws_sns_topic.target.arn}",
    ]
  }
}
