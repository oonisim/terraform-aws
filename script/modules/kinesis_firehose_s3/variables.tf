variable "PROJECT" {
  type = string
}
variable "ENV" {
  type = string
}

variable "name" {
  description = "Kinesis firehose name"
}

# Record transformation lambda
variable "lambda_alias_name" {
  description = "Kinesis Firehose transform lambda alias name"
  type = string
}
variable "lambda_function_name" {
  description = "Kinesis Firehose transform lambda function name"
  type = string
}

# S3
variable "bucket_name" {
}
variable "buffer_size" {
  description = "Firehose S3 bucket buffer size"
}
variable "buffer_interval" {
  description = "Firehose S3 bucket buffer interval"
}
variable "compression_format" {
  description = "(Optional) Default is UNCOMPRESSED, or GZIP, ZIP & Snappy. For redshift you cannot use ZIP or Snappy."
  default = "UNCOMPRESSED"
}

# Cloudwatch
variable "cloudwatch_loggroup_name" {
  description = "Cloudwatch log group"
  type = string
  default = null
}

variable "cloudwatch_logstream_name" {
  description = "Cloudwatch log stream"
  type = string
  default = null
}

