variable "PROJECT" {
  type = string
}
variable "ENV" {
  type = string
}

#--------------------------------------------------------------------------------
# S3 bucket to upload lambda
#--------------------------------------------------------------------------------
variable "bucket_name" {
  description = "S3 bucket name to use to upload the lambda package(s)"
  type = string
}

#--------------------------------------------------------------------------------
# Lambda package
#--------------------------------------------------------------------------------
variable "lambda_package_path" {
  description = "Path to the lambda package to upload"
  type = string
}
variable "lambda_package_md5" {
  description = "MD5 hash value of the lambda package file"
}
variable "lambda_file_name" {
  description = "Filename of the lamda function so as to invoke the lambda as 'lamda_file_name.handler_name'"
  type = string
}

#--------------------------------------------------------------------------------
# Lambda function
#--------------------------------------------------------------------------------
variable "iam_role_name" {
  description = "Name of the IAM Role for the lambda to use"
}
variable "lambda_handler_method" {
  description = "Handler method of the lamda function so as to invoke the lambda as 'lamda_file_name.handler_name'"
  type = string
}
variable "lambda_function_name" {
  description = "Lambda function name"
  type = string
}
variable "lambda_alias_name" {
  description = "Lambda alias name"
  type = string
}

#--------------------------------------------------------------------------------
# Lambda runtiome environment
#--------------------------------------------------------------------------------
variable "lambda_runtime" {
  description = "Runtime for the rambda"
  type = string
  default = "python3.6"
}
variable "lambda_memory_size" {
  default = "128"
  type = number
}
variable "lambda_timeout" {
  type = number
  default = "300"
}

#--------------------------------------------------------------------------------
# Environment
#--------------------------------------------------------------------------------
variable "lambda_environment_variables" {
  description = "Environment varilable of Lambda runtime"
  type = map(string)
  default = {}
}

#--------------------------------------------------------------------------------
# VPC
# vpc_config = {
#   security_group_ids = [...]
#   subnet_ids = [...]
# }
#--------------------------------------------------------------------------------
variable "vpc_config" {
  type = map(list(string))
  default = null
}

#--------------------------------------------------------------------------------
# X-Ray
# (Required) Can be either PassThrough or Active.
# If PassThrough, Lambda will only trace the request from an upstream service if it contains a tracing header with "sampled=1".
# If Active, Lambda will respect any tracing header it receives from an upstream service.
# If no tracing header is received, Lambda will call X-Ray for a tracing decision.
#--------------------------------------------------------------------------------
variable "tracing_config_mode" {
  description = "X-Ray tracing mode"
  type = string
  default = "PassThrough"
}
