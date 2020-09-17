variable "PROJECT" {
  type = string
}
variable "ENV" {
  type = string
}

#--------------------------------------------------------------------------------
# S3 bucket to upload lambda
#--------------------------------------------------------------------------------
/*
variable "bucket_name" {
  description = "S3 bucket name to use to upload the lambda package(s)"
  type = string
}
*/

#--------------------------------------------------------------------------------
# Lambda package
#--------------------------------------------------------------------------------
variable "lambda_transform_dir" {
  description = "Path to the lambda package to upload"
  type = string
}
variable "lambda_transform_file_name" {
  description = "Filename of the lamda function so as to invoke the lambda as 'lamda_file_name.handler_name'"
  type = string
}
variable "lambda_transform_template_name" {
  description = "Filename of the lambda function teamplate to run interpolation against"
  type = string
}
variable "lambda_transform_archive_name" {
  description = "Filename of the lambda function archive to upload"
  type = string
}
variable "lambda_package_transform_dir" {
  type = string
}


#--------------------------------------------------------------------------------
# Lambda function
#--------------------------------------------------------------------------------
variable "lambda_transform_handler_method" {
  description = "Handler name of the lamda function so as to invoke the lambda as 'lamda_file_name.handler_name'"
  type = string
}
variable "lambda_transform_function_name" {
  description = "Lambda function name"
  type = string
}
variable "lambda_transform_alias_name" {
  description = "Lambda alias name"
  type = string
}

#--------------------------------------------------------------------------------
# Lambda runtiome environment
#--------------------------------------------------------------------------------
variable "lambda_transform_runtime" {
  description = "Runtime for the rambda"
  default = "python3.6"
}
variable "lambda_transform_memory_size" {
  default = "128"
}
variable "lambda_transform_timeout" {
  default = "300"
}
