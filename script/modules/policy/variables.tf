variable "PROJECT" {
}
variable "ENV" {
  type = string
  description = "Target environment in the project (e.g. prd/uat/dev)"
}
variable "name" {
  type = string
  description = "Name of the target to which the set of default policies are attached."
}

variable "s3_arns" {
  description = "List of S3 bucket ARN to which the default S3 policies are applied."
  type = list
}
