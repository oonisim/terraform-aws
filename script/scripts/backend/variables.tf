variable "REGION" {
  description = "AWS account region"
}
#--------------------------------------------------------------------------------
# Project
#--------------------------------------------------------------------------------
variable "PREFIX" {
  description = "Prefix to mark TF state S3 bucket"
  type        = "string"
}
variable "PROJECT" {
  description = "The name of the environment."
  type        = "string"
}

variable "ENV" {
  description = "The name of the environment."
  type        = "string"
}
