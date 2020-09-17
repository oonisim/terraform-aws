output "cloudfront_id" {
  value = module.cf_s3_web.cloudfront_id
}

output "cloudfront_hosted_zone_id" {
  value = module.cf_s3_web.hosted_zone_id
}

output "cloudfront_domain_name" {
  value = module.cf_s3_web.cloudfront_domain_name
}