module "sagemaker_notebook" {
  # Terraform currently does not allow interpolation on the module source path.
  source = "../../../modules/s3"

  PROJECT            = var.PROJECT
  ENV                = var.ENV
  REGION             = var.REGION # Control in which region to create the bucket.
  bucket_name        = var.bucket_sagemaker_notebook_name
  bucket_description = "Bucket for SageMaker notebooks"
  cors = null
  /*
  cors = {
    # https://docs.aws.amazon.com/AmazonS3/latest/API/RESTCommonRequestHeaders.html
    # https://docs.aws.amazon.com/AmazonS3/latest/API/RESTObjectPUT.html
    allowed_headers = [
    ]
    allowed_methods = [
    ]
    allowed_origins = [
    ]
    # https://docs.aws.amazon.com/AmazonS3/latest/API/RESTCommonResponseHeaders.html
    expose_headers = [
    ]
    max_age_seconds = [
    ]
  }
  */
}

