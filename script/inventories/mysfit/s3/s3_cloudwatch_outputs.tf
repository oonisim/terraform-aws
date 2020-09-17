output "bucket_cloudwatch" {
  value = module.cloudwatch.bucket
}

output "bucket_cloudwatch_arn" {
  value = module.cloudwatch.arn
}

output "bucket_cloudwatch_domain_name" {
  value = module.cloudwatch.bucket_domain_name
}

output "bucket_cloudwatch_region" {
  value = module.cloudwatch.region
}

output "bucket_cloudwatch_hosted_zone_id" {
  value = module.cloudwatch.hosted_zone_id
}

output "bucket_cloudwatch_server_side_encryption_configuration" {
  value = module.cloudwatch.server_side_encryption_configuration
}

output "bucket_cloudwatch_versioning" {
  value = module.cloudwatch.versioning
}

output "bucket_cloudwatch_tags" {
  value = module.cloudwatch.tags
}
