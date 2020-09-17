module "sagemaker_data" {
  # Terraform currently does not allow interpolation on the module source path.
  source = "../../../modules/s3"

  PROJECT            = var.PROJECT
  ENV                = var.ENV
  REGION             = var.REGION # Control in which region to create the bucket.
  bucket_name        = var.bucket_sagemaker_data_name
  bucket_description = "Bucket for SageMaker notebooks"
  cors = null
}

