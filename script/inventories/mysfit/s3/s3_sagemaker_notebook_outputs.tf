output "bucket_sagemaker_notebook" {
  value = module.sagemaker_notebook.bucket
}

output "bucket_sagemaker_notebook_arn" {
  value = module.sagemaker_notebook.arn
}

output "bucket_sagemaker_notebook_domain_name" {
  value = module.sagemaker_notebook.bucket_domain_name
}

output "bucket_sagemaker_notebook_region" {
  value = module.sagemaker_notebook.region
}

output "bucket_sagemaker_notebook_hosted_zone_id" {
  value = module.sagemaker_notebook.hosted_zone_id
}

output "bucket_sagemaker_notebook_server_side_encryption_configuration" {
  value = module.sagemaker_notebook.server_side_encryption_configuration
}

output "bucket_sagemaker_notebook_versioning" {
  value = module.sagemaker_notebook.versioning
}

output "bucket_sagemaker_notebook_tags" {
  value = module.sagemaker_notebook.tags
}
