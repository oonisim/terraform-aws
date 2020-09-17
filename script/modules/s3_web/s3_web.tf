resource "aws_s3_bucket" "this" {
  bucket = replace("${var.PROJECT}-${var.ENV}-${var.bucket_name}", "/[_.]/", "-")
  force_destroy = true

  #--------------------------------------------------------------------------------
  # Canned ACL
  # https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl
  #--------------------------------------------------------------------------------
  # Need to remove public read permission to make sure only CF can acess.
  # https://serverfault.com/questions/923731/how-do-i-limit-s3-object-access-to-cloudfront-only
  #--------------------------------------------------------------------------------
  acl    = var.allow_cf_access_only ? "private" : "public-read"
  #--------------------------------------------------------------------------------

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  #--------------------------------------------------------------------------------
  # To invalidate CF cache upon file updates
  #--------------------------------------------------------------------------------
  versioning {
    enabled = true
  }

  tags = {
    Project = var.PROJECT
    Environment = var.ENV
    Name = var.bucket_name
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.s3_web.json
}

#--------------------------------------------------------------------------------
# Allow access only from CloudFront
#--------------------------------------------------------------------------------
data "aws_iam_policy_document" "s3_web" {
  statement {
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.this.arn
    ]

    principals {
      type = "AWS"
      identifiers = var.cf_origin_access_identity_arns
    }
  }
  statement {
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "${aws_s3_bucket.this.arn}/*"
    ]

    principals {
      type = "AWS"
      identifiers = var.cf_origin_access_identity_arns
    }
  }
}


