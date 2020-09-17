#--------------------------------------------------------------------------------
# Default S3 IAM policies.
#--------------------------------------------------------------------------------

#--------------------------------------------------------------------------------
# Objects in the S3 buckets to configure object acess policies
#--------------------------------------------------------------------------------
locals {
  s3_object_arns = "${formatlist("%s/*", var.s3_arns)}"
}

#--------------------------------------------------------------------------------
# Policy attachments to the group
# [Deprecated]
# Rather than attaching to a group, make the module generic policy factory.
# To what they are attached is up to the module consumer.
#--------------------------------------------------------------------------------
/*
resource "aws_iam_group_policy_attachment" "allow_s3" {
  group = "${var.name}"
  policy_arn = "${aws_iam_policy.allow_s3.arn}"
}
resource "aws_iam_group_policy_attachment" "deny_s3" {
  group = "${var.name}"
  policy_arn = "${aws_iam_policy.deny_s3.arn}"
}
*/

#--------------------------------------------------------------------------------
# Allow policies
#--------------------------------------------------------------------------------
resource "aws_iam_policy" "allow_s3" {
  name_prefix = "${title(var.PROJECT)}${title(var.ENV)}AllowS3Opeations"
  policy = "${data.aws_iam_policy_document.allow_s3.json}"
}
data "aws_iam_policy_document" "allow_s3" {
  # AWS console to be able to list the buckets and go inside one buckets.
  # UNIX r+x permissions on a directory to be able to see and go inside it.
  statement {
    sid = "${title(var.PROJECT)}${title(var.ENV)}S3ListAndEnterBucket"
    effect = "Allow"
    actions = [
      # For AWS S3 console to be able to list buckets
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
    ]
    resources = [
      # AWS S3 console cannot control which bucket to show. Either all or none.
      # https://stackoverflow.com/questions/6615168
      # Only acceptable resouce is * for ListAllMyBuckets
      "arn:aws:s3:::*"
    ]
  }
  statement {
    sid = "${title(var.PROJECT)}${title(var.ENV)}AllowModifyS3Bucket"
    effect = "Allow"
    actions = [
      # For AWS S3 console to get the S3 end point of the bucket that a user clicks
      "s3:ListBucketMultipartUploads",
      "s3:PutBucketVersioning",
      "s3:GetBucketVersioning",
      "s3:PutBucketTagging",
      "s3:GetBucketTagging",
      "s3:PutBucketNotification",
      "s3:GetBucketNotification",
      "s3:PutBucketWebsite",
      "s3:GetBucketWebsite",
    ]
    resources = [ "${var.s3_arns}" ]
  }
  # UNIX r permission on files to be able to see them (but not access them in S3 unlike UNIX) in the directory (bucket)
  statement {
    sid = "${title(var.PROJECT)}${title(var.ENV)}AllowListS3Objects"
    effect = "Allow"
    actions = [
      # To be able to list contents in the buckets
      "s3:ListBucket",
      # To be able to list the versioned contents in the buckets
      "s3:ListBucketVersions"
    ]
    resources = [ "${var.s3_arns}" ]
  }
  # UNIX r+w permission on files
  statement {
    sid = "${title(var.PROJECT)}${title(var.ENV)}AllowModifyS3Object"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:RestoreObject",
      "s3:PutObjectVersionTagging",
      "s3:PutBucketVersioning",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:AbortMultipartUpload",
    ]
    resources = [ "${concat(var.s3_arns, local.s3_object_arns)}" ]
  }
}

#--------------------------------------------------------------------------------
# Deny policies
#--------------------------------------------------------------------------------
resource "aws_iam_policy" "deny_s3" {
  name_prefix = "${title(var.PROJECT)}${title(var.ENV)}DenyS3Operations"
  policy = "${data.aws_iam_policy_document.deny_s3.json}"
}
data "aws_iam_policy_document" "deny_s3" {
  statement {
    sid = "${title(var.PROJECT)}${title(var.ENV)}DenyS3Operations"
    effect = "Deny"
    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:PutBucketAcl",
      "s3:GetBucketAcl",
      "s3:PutBucketPolicy",
      "s3:PutEncryptionConfiguration",
      "s3:PutInventoryConfiguration",
      "s3:PutLifecycleConfiguration",
      "s3:PutReplicationConfiguration"
    ]
    resources = [
      "arn:aws:s3:::*"
    ]
  }
}