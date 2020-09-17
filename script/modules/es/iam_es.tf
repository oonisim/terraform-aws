resource "aws_iam_role" "es" {
  name = "${replace("${title(var.PROJECT)}${title(var.ENV)}ES", "/[-_.]/", "")}"
  assume_role_policy = "${data.aws_iam_policy_document.allow_assume_es.json}"
}
data "aws_iam_policy_document" "allow_assume_es" {
  statement {
    sid = "AllowAssumeesESForCloudWatch"
    principals {
      type = "Service"
      identifiers = [
        "es.amazonaws.com"
      ]
    }
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
  }
}

#--------------------------------------------------------------------------------
# Grant AWS resources access to ES
# https://www.terraform.io/docs/providers/aws/r/elasticsearch_domain.html
#--------------------------------------------------------------------------------
data "aws_iam_policy_document" "allow_aws_access_es" {
  statement {
    sid    = "${replace("${title(var.PROJECT)}${title(var.ENV)}AllowesESAccessCloudWatch", "/[-_.]/", "")}"
    principals {
      type = "AWS"
      identifiers = [
        "*"
      ]
    }
    effect = "Allow"
    actions = [
      "es:*"
    ]
    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = var.es_source_ips
    }
    resources = [
      "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${local.domain_name}/*",
    ]
  }
}


#--------------------------------------------------------------------------------
# Grant Kinesis Data es Access CloudWatch
# https://www.terraform.io/docs/providers/aws/r/cloudwatch_log_resource_policy.html
#--------------------------------------------------------------------------------
resource "aws_cloudwatch_log_resource_policy" "allow_es_access_cloudwatch" {
  policy_name = "${replace("${title(var.PROJECT)}${title(var.ENV)}AllowesESAccessCloudWatch", "/[-_.]/", "")}"
  policy_document = "${data.aws_iam_policy_document.allow_es_access_cloudwatch.json}"
}
data "aws_iam_policy_document" "allow_es_access_cloudwatch" {
  statement {
    sid    = "${replace("${title(var.PROJECT)}${title(var.ENV)}AllowesESAccessCloudWatch", "/[-_.]/", "")}"
    principals {
      type = "Service"
      identifiers = [
        "es.amazonaws.com"
      ]
    }
    effect = "Allow"
    actions = [
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch",
      "logs:CreateLogStream"
    ]
    resources = [
      #"arn:aws:cloudwatch:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*"
      "${local.cloudwatch_loggroup_arn}",
      "${local.cloudwatch_loggroup_arn}/*"
    ]
  }
}
