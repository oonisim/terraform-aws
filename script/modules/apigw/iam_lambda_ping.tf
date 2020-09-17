#--------------------------------------------------------------------------------
# IAM policy for lambda to log into cloudwatch
#--------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "execute_lambda_ping" {
  role       = aws_iam_role.lambda_ping.id
  policy_arn = data.aws_iam_policy.enable_lambda_logging.arn
}

