#--------------------------------------------------------------------------------
# S3 bucket
#--------------------------------------------------------------------------------
resource "aws_s3_bucket" "this" {
  #  region        = var.REGION
  bucket        = replace("${var.PROJECT}-${var.ENV}-${var.bucket_name}", "/[_.@#^%*]/", "-")
  force_destroy = true

  tags = {
    Project     = var.PROJECT
    Environment = var.ENV
  }

  #--------------------------------------------------------------------------------
  # Access Control
  #--------------------------------------------------------------------------------
  acl = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  #--------------------------------------------------------------------------------
  # The content of var.cors is below.
  #   {
  #     allowed_headers = [
  #        <content_allowed_headers>
  #     ]
  #     ...
  #   }
  #
  # var.cors -> Dictionary
  # for_each [ var.cors ] -> key is none value is the dictioanry D.
  # Hence D["allowed_headers"] -> <content_allowed_headers>
  #--------------------------------------------------------------------------------
  dynamic cors_rule {
    for_each = var.cors == null ? [] : [ var.cors ]
    content {
      allowed_headers = cors_rule.value["allowed_headers"]
      allowed_methods = cors_rule.value["allowed_methods"]
      allowed_origins = cors_rule.value["allowed_origins"]
      expose_headers  = cors_rule.value["expose_headers"]
      max_age_seconds = element(cors_rule.value["max_age_seconds"], 0)
    }
  }

  #--------------------------------------------------------------------------------
  # Lifeclcle control
  #--------------------------------------------------------------------------------
  versioning {
    enabled = var.bucket_versioning
  }
  lifecycle_rule {
    id      = var.bucket_name
    enabled = var.bucket_lifecycle
    noncurrent_version_transition {
      days          = var.bucket_noncurrent_version_transition
      storage_class = "GLACIER"
    }
    transition {
      days          = var.bucket_transition_ia
      storage_class = "STANDARD_IA"
      # or "ONEZONE_IA"
    }
    transition {
      days          = var.bucket_transition_gracier
      storage_class = "GLACIER"
    }
    expiration {
      days = var.bucket_expiration
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls   = true
  block_public_policy = true

  # To avoid OperationAborted: A conflicting conditional operation is currently in progress
  depends_on = [
    aws_s3_bucket_policy.this
  ]
}