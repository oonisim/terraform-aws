module "data" {
  # Terraform currently does not allow interpolation on the module source path.
  source = "../../../modules/s3"

  PROJECT            = var.PROJECT
  ENV                = var.ENV
  REGION             = var.REGION # Control in which region to create the bucket.
  bucket_name        = var.bucket_data_name
  bucket_description = "data bucket for ${var.PROJECT}-${var.ENV}"
  cors = {
    # https://docs.aws.amazon.com/AmazonS3/latest/API/RESTCommonRequestHeaders.html
    # https://docs.aws.amazon.com/AmazonS3/latest/API/RESTObjectPUT.html
    allowed_headers = [
      "Host",
      "Authorization",
      "Date",
      "x-amz-date",
      "Content-Type",
      "Content-Length",
      "Content-MD5",
      "x-amz-content-sha256",
      "x-amz-security-token",
      "x-amz-storage-class",
      "x-amz-server-side-encryption-customer-algorithm",
    ]
    allowed_methods = [
      "GET",
      "PUT",
      "POST",
    ]
    allowed_origins = ["*"]
    # https://docs.aws.amazon.com/AmazonS3/latest/API/RESTCommonResponseHeaders.html
    expose_headers = [
      "Server",
      "Date",
      "x-amz-request-id",
      "x-amz-id-2",
    ]
    max_age_seconds = [3600]
  }
}

