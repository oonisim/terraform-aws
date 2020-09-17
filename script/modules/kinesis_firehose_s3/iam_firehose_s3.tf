resource "aws_iam_role" "firehose" {
  name = "${replace("${title(var.PROJECT)}${title(var.ENV)}Firehose", "/[-_.]/", "")}"
  assume_role_policy = "${data.aws_iam_policy_document.allow_assume_firehose.json}"
}
data "aws_iam_policy_document" "allow_assume_firehose" {
  statement {
    sid    = "${replace("${title(var.PROJECT)}${title(var.ENV)}AllowAssumeFirehoseForS3", "/[-_.]/", "")}"
    principals {
      type = "Service"
      identifiers = [
        "firehose.amazonaws.com"
      ]
    }
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    condition {
      test = "StringEquals"
      variable = "sts:ExternalId"
      values = [
        "${data.aws_caller_identity.current.account_id}"
      ]
    }
  }
}

#--------------------------------------------------------------------------------
# Grant Kinesis Data Firehose Access to an Amazon S3 Destination
# https://docs.aws.amazon.com/firehose/latest/dev/controlling-access.html#using-iam-s3
# https://www.terraform.io/docs/providers/aws/r/kinesis_firehose_delivery_stream.html#s3-destination
#--------------------------------------------------------------------------------
resource "aws_iam_role_policy" "allow_firehose_access_s3" {
  name = "${replace("${title(var.PROJECT)}${title(var.ENV)}AllowFirehoseAccessS3", "/[-_.]/", "")}"
  role = "${aws_iam_role.firehose.id}"
  policy = "${data.aws_iam_policy_document.allow_firehose_access_s3.json}"
}
data "aws_iam_policy_document" "allow_firehose_access_s3" {
  statement {
    sid    = "${replace("${title(var.PROJECT)}${title(var.ENV)}AllowFirehoseAccessS3", "/[-_.]/", "")}"
    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject"
    ]
    resources = [
      "${local.bucket_arn}",
      "${local.bucket_arn}/*",
    ]
  }
}

#--------------------------------------------------------------------------------
# Grant Kinesis Data Firehose Access Lambda
#--------------------------------------------------------------------------------
resource "aws_iam_role_policy" "allow_firehose_access_lambda" {
  name = "${replace("${title(var.PROJECT)}${title(var.ENV)}AllowFirehoseAccessLambda", "/[-_.]/", "")}"
  policy = "${data.aws_iam_policy_document.allow_firehose_access_lambda.json}"
  role = "${aws_iam_role.firehose.id}"
}
data "aws_iam_policy_document" "allow_firehose_access_lambda" {
  statement {
    sid    = "${replace("${title(var.PROJECT)}${title(var.ENV)}AllowFirehoseAccessLambda", "/[-_.]/", "")}"
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
      "lambda:GetFunctionConfiguration"
    ]
    resources = [
      "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:*"
    ]
  }
}

#--------------------------------------------------------------------------------
# IAM permission to invoke lambda via alias (qualifier)
#--------------------------------------------------------------------------------
resource "aws_lambda_permission" "allow_firehose_invoke_lambda_alias" {
  statement_id  = "${title(var.PROJECT)}${title(var.ENV)}AllowFirehoseInvokeLambda${title(data.aws_lambda_alias.transform.function_name)}${title(data.aws_lambda_alias.transform.name)}"
  principal     = "firehose.amazonaws.com"
  source_arn    = aws_kinesis_firehose_delivery_stream.s3.arn
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_alias.transform.function_name
  qualifier     = data.aws_lambda_alias.transform.name
}

#--------------------------------------------------------------------------------
# Grant Kinesis Data Firehose Access CloudWatch
#--------------------------------------------------------------------------------
resource "aws_iam_role_policy" "allow_firehose_access_cloudwatch" {
  name = "${replace("${title(var.PROJECT)}${title(var.ENV)}AllowFirehoseAccessCloudwatch", "/[-_.]/", "")}"
  policy = "${data.aws_iam_policy_document.allow_firehose_access_cloudwatch.json}"
  role = "${aws_iam_role.firehose.id}"
}
data "aws_iam_policy_document" "allow_firehose_access_cloudwatch" {
  statement {
    sid    = "${replace("${title(var.PROJECT)}${title(var.ENV)}AllowFirehoseAccessCloudWatch", "/[-_.]/", "")}"
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

