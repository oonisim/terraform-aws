#--------------------------------------------------------------------------------
# IAM policy to assume lambda service.
#--------------------------------------------------------------------------------
data "aws_iam_policy_document" "assume_lambda_service" {
  statement {
    sid    = "${var.PROJECT}${var.ENV}AssumeLambdaService"
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
    actions = ["sts:AssumeRole"]
  }
}
