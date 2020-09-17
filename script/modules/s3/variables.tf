variable "REGION" {
  description = "AWS region to be set via the TF_VAR enviornment variable"
}

variable "PROJECT" {
}

variable "ENV" {
}

variable "bucket_name" {
}

variable "bucket_description" {
}

variable "cors" {
  #--------------------------------------------------------------------------------
  # Cross-Origin Resource Sharing (CORS)
  # https://docs.aws.amazon.com/AmazonS3/latest/dev/cors.html
  #
  # Troubleshooting CORS Issues
  # https://docs.aws.amazon.com/AmazonS3/latest/dev/cors-troubleshooting.html
  #--------------------------------------------------------------------------------
  description = "CORS"
  type        = map
  default = {
    # https://docs.aws.amazon.com/AmazonS3/latest/API/RESTCommonRequestHeaders.html
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
    ]
    allowed_methods = ["GET", "POST", "PUT", "HEAD"]
    allowed_origins = [""]
    # https://docs.aws.amazon.com/AmazonS3/latest/API/RESTCommonResponseHeaders.html
    expose_headers = [
      "Server",
      "Date",
      "x-amz-request-id",
      "x-amz-id-2",
    ]
    #--------------------------------------------------------------------------------
    # Heterogeneous maps in module variables and outputs cannot be used as of now.
    # https://github.com/hashicorp/terraform/issues/14322
    # Expected to be fixed in 0.12, but for now, make it all list.
    # Otherwise error:
    # "var.cors" does not have homogenous types. found TypeList and then TypeString
    #--------------------------------------------------------------------------------
    max_age_seconds = [0]
  }
}

variable "bucket_versioning" {
  default = true
}

variable "bucket_lifecycle" {
  default = true
}

variable "bucket_noncurrent_version_transition" {
  default = 1
}

variable "bucket_transition_ia" {
  default = 30
}

variable "bucket_transition_gracier" {
  default = 60
}

variable "bucket_expiration" {
  default = 90
}

