variable "lambda_ping_runtime" {
  default = "python2.7"
}

variable "lambda_ping_dir" {
  default = "lambda/ping"
}

variable "lambda_ping_name" {
  default = "ping"
}

variable "lambda_ping_qualifier" {
  default = "latest"
}

variable "lambda_ping_file" {
  default = "ping.py"
}

variable "lambda_ping_archive" {
  default = "lambda/ping.zip"
}

variable "lambda_ping_handler" {
  default = "ping.lambda_handler"
}

