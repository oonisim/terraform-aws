#--------------------------------------------------------------------------------
# S3 bucket for the ECS service.
# TODO: Establish the ratioale either having a S3 bucket for each ECS service, or share one S3 among services.
#--------------------------------------------------------------------------------
resource "aws_s3_bucket" "lb_log" {
  region        = var.REGION
  bucket        = replace("${var.PROJECT}-${var.ENV}-alb-log-${var.bucket_log_name}", "/[_.@~*&%=]/", "-")

  force_destroy = true

  tags = {
    Project = var.PROJECT
    Env     = var.ENV
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
  # Lifeclcle control
  #--------------------------------------------------------------------------------
  versioning {
    enabled = var.bucket_versioning
  }
  lifecycle_rule {
    id      = "${var.PROJECT}-${var.ENV}-${var.bucket_log_name}"
    enabled = var.bucket_lifecycle
    noncurrent_version_transition {
      days          = var.bucket_noncurrent_version_transition
      storage_class = "GLACIER"
    }
    transition {
      days          = var.bucket_transition_ia
      storage_class = "STANDARD_IA" # or "ONEZONE_IA"
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

#--------------------------------------------------------------------------------
# Expose I/F
# Indirection/Interfacce to avoid direct reference to the implementation
# Make sure to program against interface, not against implementation.
# Otherwise implementation change/name change causes cascading changes.
#--------------------------------------------------------------------------------
locals {
  bucket_alb_log_arn =aws_s3_bucket.lb_log.arn
  bucket_alb_log_id  = aws_s3_bucket.lb_log.id
}

