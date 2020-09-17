variable "lambda_kinesis_consumer_runtime" {
  default = "python2.7"
}
variable "lambda_kinesis_consumer_dir" {
  default = "lambda/python"
}
variable "lambda_kinesis_consumer_name" {
  default = "kinesis_consumer"
}
variable "lambda_kinesis_consumer_qualifier" {
  default = "latest"
}
variable "lambda_kinesis_consumer_template" {
  default = "kinesis_consumer.py.tpl"
}
variable "lambda_kinesis_consumer_file" {
  default = "kinesis_consumer.py"
}
variable "lambda_kinesis_consumer_archive_dir" {
  default = "lambda/packages"
}
variable "lambda_kinesis_consumer_archive" {
  default = "kinesis_consumer.zip"
}
variable "lambda_kinesis_consumer_handler" {
  default = "kinesis_consumer.lambda_handler"
}
variable "lambda_kinesis_consumer_function_version" {
  default = "$LATEST"
}

variable "lambda_kinesis_consumer_trigger" {
  description = "A file to trigger re-packaging lambda function kinesis_consumer zip"
  default = "lambda/python/trigger"
}