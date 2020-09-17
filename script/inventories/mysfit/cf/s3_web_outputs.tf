output "s3_web_bucket_name" {
  value = local.s3_web_bucket_name
}
output "s3_web_bucket_domain_name" {
  value = local.s3_web_bucket_domain_name
}
output "s3_web_index_html_id" {
  value = [
    for o in aws_s3_bucket_object.web_files: o.id
  ]
}