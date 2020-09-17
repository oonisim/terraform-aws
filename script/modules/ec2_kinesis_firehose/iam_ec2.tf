# IAM role for EC2
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ec2_instance_profile" {
  name               = "${var.PROJECT}_${var.ENV}_ec2_instance_profile"
  assume_role_policy = "${data.aws_iam_policy_document.ec2_assume_role.json}"
}

resource "aws_iam_role_policy_attachment" "ec2_instance_profile" {
  role       = "${aws_iam_role.ec2_instance_profile.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.PROJECT}_${var.ENV}_${aws_iam_role.ec2_instance_profile.name}"
  role = "${aws_iam_role.ec2_instance_profile.name}"
}


#--------------------------------------------------------------------------------
# IAM policy allow S3 access
#--------------------------------------------------------------------------------
resource "aws_iam_role_policy" "allow_s3" {
  name   = "${replace("${title("${var.PROJECT}")}${title("${var.ENV}")}AllowAccessS3", "/[-_.]/", "")}"
  role   = "${aws_iam_role.ec2_instance_profile.id}"
  policy = data.aws_iam_policy_document.allow_s3.json
}

data "aws_iam_policy_document" "allow_s3" {
  statement {
    sid    = "${replace("${title("${var.PROJECT}")}${title("${var.ENV}")}AllowAccessS3", "/[-_.]/", "")}"
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:Put*",
      "s3:List*",
      "s3:*MultipartUpload*",
      "s3:PutBucketAcl",
      "s3:PutObjectAcl",
    ]
    resources = [
      "${local.bucket_arn}",
      "${local.bucket_arn}/*",
    ]
  }
  statement {
    sid    = "DenyAlterS3"
    effect = "Deny"
    actions = [
      "s3:*Delete*",
      "s3:*Policy*",
    ]
    resources = [
      "*",
    ]
  }
}

#--------------------------------------------------------------------------------
# Permission to access EFS
# https://docs.aws.amazon.com/efs/latest/ug/efs-api-permissions-ref.html
# https://docs.aws.amazon.com/efs/latest/ug/access-control-managing-permissions.html
# https://console.aws.amazon.com/iam/home?#/policies/arn:aws:iam::aws:policy/AmazonElasticFileSystemReadOnlyAccess$jsonEditor
#--------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "allow_ec2_read_efs" {
  role       = "${aws_iam_role.ec2_instance_profile.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemReadOnlyAccess"
}
resource "aws_iam_role_policy" "allow_ec2_access_efs" {
  name   = "${var.PROJECT}_${var.ENV}_allow_access_efs"
  role   = "${aws_iam_role.ec2_instance_profile.id}"
  policy = data.aws_iam_policy_document.allow_ec2_access_efs.json
}

data "aws_iam_policy_document" "allow_ec2_access_efs" {
  statement {
    sid    = "${replace("${title("${var.PROJECT}")}${title("${var.ENV}")}AllowAccessEFS", "/[-_.]/", "")}"
    effect = "Allow"
    actions = [
      "elasticfilesystem:CreateMountTarget",
      "elasticfilesystem:CreateTags",
      "elasticfilesystem:Describe*",
    ]

    resources = [
      "arn:aws:elasticfilesystem:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:file-system/*"
    ]
  }
  statement {
    sid    = "${replace("${title("${var.PROJECT}")}${title("${var.ENV}")}MountEFSOnEC2", "/[-_.]/", "")}"
    effect = "Allow"
    actions = [
      "ec2:DescribeSubnets",
      "ec2:CreateNetworkInterface",
      "ec2:Describe*"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid    = "${replace("${title("${var.PROJECT}")}${title("${var.ENV}")}DenyAlterEFS", "/[-_.]/", "")}"
    effect = "Deny"
    actions = [
      "elasticfilesystem:DeleteFileSystem*",
    ]
    resources = [
      "*"
    ]
  }
}


#--------------------------------------------------------------------------------
# Permission to access Kinesis Firehose
# https://docs.aws.amazon.com/firehose/latest/dev/controlling-access.html#using-iam-rs
#--------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "allow_ec2_read_firehose" {
  role       = "${aws_iam_role.ec2_instance_profile.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonKinesisFirehoseReadOnlyAccess"
}
resource "aws_iam_role_policy" "allow_ec2_access_firehose" {
  name   = "${var.PROJECT}_${var.ENV}_allow_access_firehose"
  role   = "${aws_iam_role.ec2_instance_profile.id}"
  policy = "${data.aws_iam_policy_document.allow_ec2_access_firehose.json}"
}

data "aws_iam_policy_document" "allow_ec2_access_firehose" {
  statement {
    sid    = "${replace("${title("${var.PROJECT}")}${title("${var.ENV}")}AllowAccessFirehose", "/[-_.]/", "")}"
    effect = "Allow"
    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch",
      "firehose:UpdateDestination"
    ]
    resources = [
      #--------------------------------------------------------------------------------
      # "arn:aws:firehose:region:account-id:deliverystream/delivery-stream-name"
      #--------------------------------------------------------------------------------
      #"arn:aws:firehose:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:deliverystream/*"
      "*"
    ]
  }
  statement {
    sid    = "${replace("${title("${var.PROJECT}")}${title("${var.ENV}")}DenyAlterFirehose", "/[-_.]/", "")}"
    effect = "Deny"
    actions = [
      "firehose:DeleteDeliveryStream",
    ]
    resources = [
      "*"
    ]
  }
}

#--------------------------------------------------------------------------------
# Grant EC2 access CloudWatch
#--------------------------------------------------------------------------------
resource "aws_iam_role_policy" "allow_ec2_access_cloudwatch" {
  name   = "${var.PROJECT}_${var.ENV}_allow_access_cloudwatch"
  role   = "${aws_iam_role.ec2_instance_profile.id}"
  policy = "${data.aws_iam_policy_document.allow_ec2_access_cloudwatch.json}"
}
data "aws_iam_policy_document" "allow_ec2_access_cloudwatch" {
  statement {
    sid    = "AllowesEC2AccessCloudWatch"
    effect = "Allow"
    actions = [
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch",
      "logs:CreateLogStream"
    ]
    resources = [
      "${local.cloudwatch_loggroup_arn}",
      "${local.cloudwatch_loggroup_arn}/*"
    ]
  }
}
