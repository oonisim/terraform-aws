#--------------------------------------------------------------------------------
# IAM role and service policy to assume lambda service.
#--------------------------------------------------------------------------------
# Use the one passed from the module client.
resource "aws_iam_role" "lambda_transform" {
  name               = replace("${var.PROJECT}_${var.ENV}_lambda_${var.lambda_transform_function_name}", "/[.@~*&%= ]/", "_")
  description        = "Role for lambda to assume"
  assume_role_policy = data.aws_iam_policy_document.assume_lambda_service.json
}
data "aws_iam_policy_document" "assume_lambda_service" {
  statement {
    sid    = replace("${title(lower(var.PROJECT))}${title(lower(var.ENV))}AssumeLambdaService", "/[_.@~*&%= ]/", "")
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

# Expose I/F
locals {
  iam_role_lambda_transform = aws_iam_role.lambda_transform.name
}
