variable "PROJECT" {
}

variable "ENV" {
}

variable "bucket_name" {
}

variable "bucket_description" {
}

variable "cf_origin_access_identity_arns" {
  type = list(string)
}

variable "bucket_versioning" {
  # Set to true for CloudFront to pick up the content changes
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

variable "allow_cf_access_only" {
  description = "Binary flag to allow access from Cloudfront only"
  type = bool
  default = false
}
