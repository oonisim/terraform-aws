output "bucket" {
  value = aws_s3_bucket.this.bucket
}

output "arn" {
  value = aws_s3_bucket.this.arn
}

output "bucket_domain_name" {
  value = aws_s3_bucket.this.bucket_domain_name
}

output "hosted_zone_id" {
  value = aws_s3_bucket.this.hosted_zone_id
}

output "region" {
  value = aws_s3_bucket.this.region
}

output "server_side_encryption_configuration" {
  value = aws_s3_bucket.this.server_side_encryption_configuration
}

output "versioning" {
  value = aws_s3_bucket.this.versioning
}

output "tags" {
  value = aws_s3_bucket.this.tags
}

/*
output "website" {
  value = "${aws_s3_bucket.this.website}"
}
output "website_domain" {
  value = "${aws_s3_bucket.this.website_domain}"
}
  output "website_endpoint" {
    value = "${aws_s3_bucket.this.website_endpoint}"
}
*/
