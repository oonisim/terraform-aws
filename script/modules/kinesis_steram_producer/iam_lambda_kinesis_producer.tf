#--------------------------------------------------------------------------------
# IAM managed policy to access Cognito as a power user.
#--------------------------------------------------------------------------------
data "aws_iam_policy" "access_cognito" {
  arn = "arn:aws:iam::aws:policy/AmazonCognitoPowerUser"
}
resource "aws_iam_role_policy_attachment" "access_cognito" {
  role       = "${aws_iam_role.lambda_kinesis_producer.id}"
  policy_arn = "${data.aws_iam_policy.access_cognito.arn}"
}
#--------------------------------------------------------------------------------
# IAM policy for lambda to log into cloudwatch
#--------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "execute_lambda_kinesis_producer" {
  role       = "${aws_iam_role.lambda_kinesis_producer.id}"
  policy_arn = "${data.aws_iam_policy.enable_lambda_logging.arn}"
}
#--------------------------------------------------------------------------------
# IAM policy to assume access S3.
#--------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "lambda_kinesis_producer_access_s3" {
  role       = "${aws_iam_role.lambda_kinesis_producer.id}"
  policy_arn = "${aws_iam_policy.lambda_kinesis_producer_access_s3.arn}"
}
resource "aws_iam_policy" "lambda_kinesis_producer_access_s3" {
  name_prefix = "${title(var.PROJECT)}${title(var.ENV)}_${title(aws_lambda_function.kinesis_producer.function_name)}AccessS3"
  policy = "${data.aws_iam_policy_document.lambda_kinesis_producer_access_s3.json}"
}
data "aws_iam_policy_document" "lambda_kinesis_producer_access_s3" {
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
# IAM policy to assume access Dynamo.
# https://aws.amazon.com/blogs/security/how-to-create-an-aws-iam-policy-to-grant-aws-lambda-access-to-an-amazon-dynamodb-table/
# https://www.olicole.net/blog/2017/07/terraforming-aws-a-serverless-website-backend-part-1/
#--------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "allow_lambda_access_dynamodb" {
  role       = "${aws_iam_role.lambda_kinesis_producer.id}"
  policy_arn = "${aws_iam_policy.allow_lambda_access_dynamodb.arn}"
}
resource "aws_iam_policy" "allow_lambda_access_dynamodb" {
  name_prefix = "${title(var.PROJECT)}${title(var.ENV)}_Allow${title(aws_lambda_function.kinesis_producer.function_name)}AccessDynamoDB"
  policy = "${data.aws_iam_policy_document.allow_lambda_access_dynamodb.json}"
}
data "aws_iam_policy_document" "allow_lambda_access_dynamodb" {
  statement {
    sid    = "Dynamo"
    effect = "Allow"
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:BatchWriteItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem"
    ]
    resources = [
      "${data.aws_dynamodb_table.job.arn}",
    ]
  }
}
#--------------------------------------------------------------------------------
# IAM policy to assume access Dynamo.
# https://aws.amazon.com/blogs/security/how-to-create-an-aws-iam-policy-to-grant-aws-lambda-access-to-an-amazon-dynamodb-table/
# https://www.olicole.net/blog/2017/07/terraforming-aws-a-serverless-website-backend-part-1/
#--------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "allow_lambda_access_kinesis" {
  role       = "${aws_iam_role.lambda_kinesis_producer.id}"
  policy_arn = "${aws_iam_policy.allow_lambda_access_kinesis.arn}"
}
resource "aws_iam_policy" "allow_lambda_access_kinesis" {
  name_prefix = "${title(var.PROJECT)}${title(var.ENV)}_Allow${title(aws_lambda_function.kinesis_producer.function_name)}AccessKinesisStream"
  policy = "${data.aws_iam_policy_document.allow_lambda_access_kinesis.json}"
}
data "aws_iam_policy_document" "allow_lambda_access_kinesis" {
  statement {
    sid    = "Kinesis"
    effect = "Allow"
    actions = [
      "kinesis:Get*",
      "kinesis:PutRecord",
      "kinesis:PutRecords",
      "kinesis:Describe*",
      "kinesis:List*",
      "kinesis:AddTagsToStream"
    ]
    resources = [
      "${data.aws_kinesis_stream.source.arn}",
    ]
  }
}

