#--------------------------------------------------------------------------------
# IAM managed policy to access Cognito as a power user.
#--------------------------------------------------------------------------------
data "aws_iam_policy" "access_cognito" {
  arn = "arn:aws:iam::aws:policy/AmazonCognitoPowerUser"
}

resource "aws_iam_role_policy_attachment" "access_cognito" {
  role       = aws_iam_role.lambda_signin.id
  policy_arn = data.aws_iam_policy.access_cognito.arn
}

#--------------------------------------------------------------------------------
# IAM policy for lambda to log into cloudwatch
#--------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "execute_lambda_signin" {
  role       = aws_iam_role.lambda_signin.id
  policy_arn = data.aws_iam_policy.enable_lambda_logging.arn
}

