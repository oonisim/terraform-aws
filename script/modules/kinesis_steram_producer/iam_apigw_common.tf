#--------------------------------------------------------------------------------
# Attache to the account the IAM role for API Gateway to log into CloudWatch.
# See the AmazonAPIGatewayPushToCloudWatchLogs predefined managed policy.
#--------------------------------------------------------------------------------
data "aws_iam_policy_document" "assume_apigateway_service" {
  statement {
    sid    = "1"
    effect = "Allow"

    principals {
      identifiers = [
        "apigateway.amazonaws.com"
      ]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role" "apigateway_logging" {
  name               = "${var.PROJECT}APIGatewayLogging"
  description        = "Serveless Architecture on AWS role for api gateway to access cloud watch"
  assume_role_policy = "${data.aws_iam_policy_document.assume_apigateway_service.json}"
}
data "aws_iam_policy" "apigateway_logging" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}
resource "aws_iam_role_policy_attachment" "apigateway_logging" {
  role       = "${aws_iam_role.apigateway_logging.id}"
  policy_arn = "${data.aws_iam_policy.apigateway_logging.arn}"
}
