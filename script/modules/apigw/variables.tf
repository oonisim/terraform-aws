#--------------------------------------------------------------------------------
# Project
#--------------------------------------------------------------------------------
variable "PROJECT" {
}

variable "ENV" {
}

#--------------------------------------------------------------------------------
# Cognito
#--------------------------------------------------------------------------------
variable "identity_authorization_type" {
}

variable "identity_provider_name" {
}

#--------------------------------------------------------------------------------
# API
#--------------------------------------------------------------------------------
variable "api_name" {
  description = "API gateway name"
}

variable "api_description" {
  description = "API description"
}

variable "api_path" {
  description = "API root reource path"
}

variable "api_version" {
  description = "API version e.g. v1"
}

variable "api_gateway_authorization" {
  description = "API gateway method authorization technology"
  default     = "COGNITO_USER_POOLS"
}

#--------------------------------------------------------------------------------
# S3 bucket
# - To presign to upload the project data.
# - To upload packages e.g. lambda function packages
#--------------------------------------------------------------------------------
variable "bucket" {
  description = "S3 bucket to load the data for execution"
}

#--------------------------------------------------------------------------------
# X-Ray
#--------------------------------------------------------------------------------
variable "xray_tracing_enabled" {
  description = "Flag to enable|disable X-ray. Default false"
  default = false
}

#--------------------------------------------------------------------------------
# Lambda functions to integrate (identity_pool)
#--------------------------------------------------------------------------------
variable "lambda_signin_function_name" {
}

variable "lambda_signin_qualifier" {
}

variable "lambda_create_function_name" {
}

variable "lambda_create_qualifier" {
}

variable "lambda_monitor_function_name" {
}

variable "lambda_monitor_qualifier" {
}

variable "lambda_delete_function_name" {
}

variable "lambda_delete_qualifier" {
}

