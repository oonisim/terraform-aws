resource "aws_iam_role" "api_click" {
  name               = "${var.PROJECT}_${var.ENV}_apigw_call_firehose"
  description        = "API Gateway to call Firehose API"
  assume_role_policy = data.aws_iam_policy_document.api_click_assume_apigateway_service.json
}

data "aws_iam_policy_document" "api_click_assume_apigateway_service" {
  statement {
    sid    = "AssumeAPIGatewayService"
    effect = "Allow"

    principals {
      identifiers = [
        "apigateway.amazonaws.com",
      ]
      type = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "allow_apigw_call_firehose" {
  role       = aws_iam_role.api_click.id
  policy_arn = aws_iam_policy.allow_apigw_call_firehose.arn
}

resource "aws_iam_policy" "allow_apigw_call_firehose" {
  name        = replace("${title(var.PROJECT)}${title(var.ENV)}AllowAPIGWCallFirehose", "/[-_.$%^&*#@]/", "")
  description = "Allow API GW to call Firehose API"
  policy = data.aws_iam_policy_document.allow_apigw_call_firehose.json
}

data "aws_iam_policy_document" "allow_apigw_call_firehose" {
  statement {
    sid    = replace("${title(var.PROJECT)}${title(var.ENV)}AllowAPIGWCallFirehose", "/[-_.$%^&*#@]/", "")
    effect = "Allow"
    actions = [
      "firehose:PutRecord"
    ]
    resources = [
      local.firehose_arn
    ]
  }
}

