#--------------------------------------------------------------------------------
# Policy to deny non TLS access to S3 objects
# https://aws.amazon.com/blogs/security/how-to-use-bucket-policies-and-apply-defense-in-depth-to-help-secure-your-amazon-s3-data/
# Policy to prevent publicly accessble S3 objects.
# https://aws.amazon.com/blogs/security/how-to-use-bucket-policies-and-apply-defense-in-depth-to-help-secure-your-amazon-s3-data/
#--------------------------------------------------------------------------------
# [S3 Block Public Access]
# Yet to be implemented in Terraform (https://github.com/terraform-providers/terraform-provider-aws/issues/6489

# Amazon S3 Block Public Access – Another Layer of Protection for Your Accounts and Buckets by Jeff Barr | on 15 NOV 2018
# https://aws.amazon.com/blogs/aws/amazon-s3-block-public-access-another-layer-of-protection-for-your-accounts-and-buckets/
#--------------------------------------------------------------------------------
resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "this" {
  statement {
    sid    = "${title(var.PROJECT)}${title(var.ENV)}DenyNonTLSAccess"
    effect = "Deny"
    principals {
      identifiers = [
        "*",
      ]
      type = "AWS"
    }
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "${aws_s3_bucket.this.arn}/*",
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values = [
        false,
      ]
    }
  }
  statement {
    sid    = "${title(var.PROJECT)}${title(var.ENV)}DenyPublicReadACL"
    effect = "Deny"
    principals {
      identifiers = [
        "*",
      ]
      type = "AWS"
    }
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]
    resources = [
      "${aws_s3_bucket.this.arn}/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values = [
        "public-read",
        "public-read-write",
        "authenticated-read",
      ]
    }
  }
  statement {
    sid    = "${title(var.PROJECT)}${title(var.ENV)}DenyPublicReadGrant"
    effect = "Deny"
    principals {
      identifiers = [
        "*",
      ]
      type = "AWS"
    }
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]
    resources = [
      "${aws_s3_bucket.this.arn}/*",
    ]
    condition {
      test     = "StringLike"
      variable = "s3:x-amz-grant-read"
      values = [
        "*http://acs.amazonaws.com/groups/global/AllUsers*",
        "*http://acs.amazonaws.com/groups/global/AuthenticatedUsers*",
      ]
    }
  }
  statement {
    sid    = "${title(var.PROJECT)}${title(var.ENV)}DenyPublicListACL"
    effect = "Deny"
    principals {
      identifiers = [
        "*",
      ]
      type = "AWS"
    }
    actions = [
      "s3:PutBucketAcl",
    ]
    resources = [
      aws_s3_bucket.this.arn,
    ]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values = [
        "public-read",
        "public-read-write",
        "authenticated-read",
      ]
    }
  }
  statement {
    sid    = "${title(var.PROJECT)}${title(var.ENV)}DenyPublicListGrant"
    effect = "Deny"
    principals {
      identifiers = [
        "*",
      ]
      type = "AWS"
    }
    actions = [
      "s3:PutBucketAcl",
    ]
    resources = [
      aws_s3_bucket.this.arn,
    ]
    condition {
      test     = "StringLike"
      variable = "s3:x-amz-grant-read"
      values = [
        "*http://acs.amazonaws.com/groups/global/AllUsers*",
        "*http://acs.amazonaws.com/groups/global/AuthenticatedUsers*",
      ]
    }
  }
}

