variable "lambda_kinesis_producer_runtime" {
  default = "python2.7"
}
variable "lambda_kinesis_producer_dir" {
  default = "lambda/python"
}
variable "lambda_kinesis_producer_name" {
  default = "kinesis_producer"
}
variable "lambda_kinesis_producer_qualifier" {
  default = "latest"
}
variable "lambda_kinesis_producer_template" {
  default = "kinesis_producer.py.tpl"
}
variable "lambda_kinesis_producer_file" {
  default = "kinesis_producer.py"
}
variable "lambda_kinesis_producer_archive_dir" {
  default = "lambda/packages"
}
variable "lambda_kinesis_producer_archive" {
  default = "kinesis_producer.zip"
}
variable "lambda_kinesis_producer_handler" {
  default = "kinesis_producer.lambda_handler"
}
variable "lambda_kinesis_producer_function_version" {
  default = "$LATEST"
}

variable "lambda_kinesis_producer_trigger" {
  description = "A file to trigger re-packaging lambda function kinesis_producer zip"
  default = "lambda/python/trigger"
}