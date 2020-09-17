#--------------------------------------------------------------------------------
# Lambda package
#--------------------------------------------------------------------------------
variable "lambda_receive_question_dir" {
  description = "Path to the lambda package to upload"
  type = string
}
variable "lambda_receive_question_file_name" {
  description = "Filename of the lamda function so as to invoke the lambda as 'lamda_file_name.handler_name'"
  type = string
}
variable "lambda_receive_question_template_name" {
  description = "Filename of the lambda function teamplate to run interpolation against"
  type = string
}
variable "lambda_receive_question_archive_name" {
  description = "Filename of the lambda function archive to upload"
  type = string
}
variable "lambda_receive_question_package_dir" {
  type = string
}


#--------------------------------------------------------------------------------
# Lambda function
#--------------------------------------------------------------------------------
variable "lambda_receive_question_handler_method" {
  description = "Handler name of the lamda function so as to invoke the lambda as 'lamda_file_name.handler_name'"
  type = string
}
variable "lambda_receive_question_function_name" {
  description = "Lambda function name"
  type = string
}
variable "lambda_receive_question_alias_name" {
  description = "Lambda alias name"
  type = string
}

#--------------------------------------------------------------------------------
# Lambda runtiome environment
#--------------------------------------------------------------------------------
variable "lambda_receive_question_runtime" {
  description = "Runtime for the rambda"
  default = "python3.6"
}
variable "lambda_receive_question_memory_size" {
  default = "128"
}
variable "lambda_receive_question_timeout" {
  default = "300"
}