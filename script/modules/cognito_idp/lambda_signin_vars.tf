variable "lambda_signin_runtime" {
  default = "python2.7"
}

variable "lambda_signin_memory_size" {
  default = "128"
}

variable "lambda_signin_timeout" {
  default = "300"
}

variable "lambda_signin_dir" {
  default = "lambda/python"
}

variable "lambda_signin_name" {
  default = "signin"
}

variable "lambda_signin_qualifier" {
  default = "latest"
}

variable "lambda_signin_template" {
  default = "identity_aws_cognito.py.template"
}

variable "lambda_signin_file" {
  default = "signin.py"
}

variable "lambda_signin_archive_dir" {
  default = "lambda/packages"
}

variable "lambda_signin_archive" {
  default = "signin.zip"
}

variable "lambda_signin_handler" {
  default = "signin.lambda_handler"
}

variable "lambda_signin_function_version" {
  default = "$LATEST"
}

variable "lambda_signin_s3_presigned_expiry" {
  description = "lambda_signin S3 presigned URL expiry seconds"
  default     = 7200
}

variable "lambda_signin_trigger" {
  description = "A file to trigger re-packaging lambda function signin zip"
  default     = "lambda/python/trigger"
}

