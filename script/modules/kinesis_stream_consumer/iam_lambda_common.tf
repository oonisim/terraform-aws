#--------------------------------------------------------------------------------
# IAM policy to assume lambda service.
#--------------------------------------------------------------------------------
data "aws_iam_policy_document" "assume_lambda_service" {
  statement {
    sid    = "AssumeLambdaService"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
    actions = ["sts:AssumeRole"]
  }
}
#--------------------------------------------------------------------------------
# IAM policy for lambda to log into cloudwatch
# Use pre-defined AWSLambdaExecute which has S3 and CloudWatch permissions.
#--------------------------------------------------------------------------------
data "aws_iam_policy" "enable_lambda_logging" {
  arn = "arn:aws:iam::aws:policy/AWSLambdaExecute"
}
