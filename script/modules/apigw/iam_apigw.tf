data "aws_iam_policy_document" "assume_apigateway_service" {
  statement {
    sid    = "1"
    effect = "Allow"

    principals {
      identifiers = [
        "apigateway.amazonaws.com",
      ]
      type        = "Service"
    }
    actions = [
      "sts:AssumeRole"]
  }
}

#--------------------------------------------------------------------------------
# Role/permissions for API Gateway CloudWatch Logging
# See the AmazonAPIGatewayPushToCloudWatchLogs predefined managed policy.
# https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-logging.html#set-up-access-logging-permissions
#--------------------------------------------------------------------------------
resource "aws_iam_role" "apigateway" {
  name               = "${var.PROJECT}_${var.ENV}_apigw_logging"
  description        = "API gateway to access cloud watch"
  assume_role_policy = data.aws_iam_policy_document.assume_apigateway_service.json
}

data "aws_iam_policy" "allow_apigateway_cloudwatch_logging" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_iam_role_policy_attachment" "apigateway_logging" {
  role       = aws_iam_role.apigateway.id
  policy_arn = data.aws_iam_policy.allow_apigateway_cloudwatch_logging.arn
}

#--------------------------------------------------------------------------------
# Note that aws_cloudwatch_log_resource_policy below would be duplicate as
# IAM role apigateway_logging should handle it.
# https://www.terraform.io/docs/providers/aws/r/cloudwatch_log_resource_policy.html
# https://stackoverflow.com/questions/48912529/what-resources-does-aws-cloudwatch-log-resource-policy-create
#--------------------------------------------------------------------------------
resource "aws_cloudwatch_log_resource_policy" "cloudwatch_log_publishing_policy" {
  policy_document = data.aws_iam_policy_document.allow_apigateway_publish_to_cloudwatch.json
  policy_name     = "${var.PROJECT}_${var.ENV}_apigw_log_publishing"
}

data "aws_iam_policy_document" "allow_apigateway_publish_to_cloudwatch" {
  statement {
    sid    = "${title(var.PROJECT)}${title(var.ENV)}AllowAPIGWLogging"
    effect = "Allow"

    principals {
      identifiers = [
        "apigateway.amazonaws.com",
      ]
      type        = "Service"
    }
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
    ]
  }
}

#--------------------------------------------------------------------------------
# X-Ray
#--------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "allow_apigateway_access_xray" {
  role       = aws_iam_role.apigateway.id
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}
