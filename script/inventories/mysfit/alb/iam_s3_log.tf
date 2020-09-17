#--------------------------------------------------------------------------------
# Allow Access Logs for Your Application Load Balancer
#--------------------------------------------------------------------------------
# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html#access-logging-bucket-permissions
# https://www.terraform.io/docs/providers/aws/d/elb_service_account.html
#--------------------------------------------------------------------------------
resource "aws_s3_bucket_policy" "allow_alb_access_bucket_elb_log" {
  bucket = local.bucket_alb_log_id
  policy = data.aws_iam_policy_document.allow_alb_access_bucket_elb_log.json
}

data "aws_elb_service_account" "main" {
}

data "aws_iam_policy_document" "allow_alb_access_bucket_elb_log" {
  statement {
    sid       = replace("${var.PROJECT}${var.ENV}AllowALBPutLotToS3${title(local.bucket_alb_log_id)}", "/[-_.]/", "")
    actions   = ["s3:PutObject"]
    resources = [
      local.bucket_alb_log_arn,
      "${local.bucket_alb_log_arn}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = [
        #"arn:aws:iam::${data.aws_elb_service_account.main.id}:root"
        data.aws_elb_service_account.main.arn
      ]
    }
  }
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
  statement {
    sid    = replace("${title(var.PROJECT)}${title(var.ENV)}${title(local.bucket_alb_log_id)}DenyNonTLSAccess", "/[-_.]/", "")
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
      "${local.bucket_alb_log_arn}/*",
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
    sid    = replace("${title(var.PROJECT)}${title(var.ENV)}${title(local.bucket_alb_log_id)}DenyPublicReadACL", "/[-_.]/", "")
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
      "${local.bucket_alb_log_arn}/*",
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
    sid    = replace("${title(var.PROJECT)}${title(var.ENV)}${title(local.bucket_alb_log_id)}DenyPublicReadGrant", "/[-_.]/", "")
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
      "${local.bucket_alb_log_arn}/*",
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
    sid    = replace("${title(var.PROJECT)}${title(var.ENV)}${title(local.bucket_alb_log_id)}DenyPublicListACL", "/[-_.]/", "")
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
      "${local.bucket_alb_log_arn}",
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
    sid    = replace("${title(var.PROJECT)}${title(var.ENV)}${title(local.bucket_alb_log_id)}DenyPublicListGrant", "/[-_.]/", "")
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
      "${local.bucket_alb_log_arn}",
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

resource "aws_s3_bucket_public_access_block" "lb_log" {
  bucket = local.bucket_alb_log_id

  block_public_acls   = true
  block_public_policy = true

  #--------------------------------------------------------------------------------
  # To avoid OperationAborted: A conflicting conditional operation is currently in progress
  # https://stackoverflow.com/questions/21188561/amazon-s3-error-a-conflicting-conditional-operation-is-currently-in-progress-ag
  #--------------------------------------------------------------------------------
  depends_on = [
    aws_s3_bucket_policy.allow_alb_access_bucket_elb_log
  ]
}


