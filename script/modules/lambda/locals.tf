locals {
  bucket_arn = data.aws_s3_bucket.this.arn
  iam_role_id = data.aws_iam_role.this.id
}