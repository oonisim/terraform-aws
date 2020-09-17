
#--------------------------------------------------------------------------------
# IAM policy for lambda to log into cloudwatch
#--------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "execute_lambda" {
  role       = local.iam_role_id
  policy_arn = data.aws_iam_policy.enable_lambda_logging.arn
}

#--------------------------------------------------------------------------------
# IAM policy for lambda to log into cloudwatch
# Use pre-defined AWSLambdaExecute which has S3 and CloudWatch permissions.
#--------------------------------------------------------------------------------
data "aws_iam_policy" "enable_lambda_logging" {
  arn = "arn:aws:iam::aws:policy/AWSLambdaExecute"
}

#--------------------------------------------------------------------------------
# IAM managed policy to access Cognito as a power user for authorizer
#--------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "allow_lambda_access_cognito" {
  role       = local.iam_role_id
  policy_arn = data.aws_iam_policy.allow_lambda_access_cognito.arn
}
data "aws_iam_policy" "allow_lambda_access_cognito" {
  arn = "arn:aws:iam::aws:policy/AmazonCognitoPowerUser"
}

#--------------------------------------------------------------------------------
# IAM policy to assume access S3 to upload the lambda package
#--------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "allow_lambda_access_s3" {
  role       = local.iam_role_id
  policy_arn = aws_iam_policy.allow_lambda_access_s3.arn
}

resource "aws_iam_policy" "allow_lambda_access_s3" {
  name_prefix = replace("${title(var.PROJECT)}${title(var.ENV)}Allow${title(var.lambda_function_name)}AccessS3", "/[-_.#$&^%@]/", "")
  policy      = data.aws_iam_policy_document.allow_lambda_access_s3.json
}

data "aws_iam_policy_document" "allow_lambda_access_s3" {
  statement {
    sid     = replace("${title(var.PROJECT)}${title(var.ENV)}Allow${title(var.lambda_function_name)}AccessS3", "/[-_.#$&^%@]/", "")
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      data.aws_s3_bucket.this.arn,
      "${data.aws_s3_bucket.this.arn}/*",
    ]
  }
}
