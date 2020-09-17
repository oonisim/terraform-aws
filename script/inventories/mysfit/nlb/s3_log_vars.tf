variable "bucket_log_name" {
  description = "Load balancer log bucket"
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

