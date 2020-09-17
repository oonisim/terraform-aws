variable "firehose_name" {
  description = "Kinesis firehose name"
}

variable "buffer_size" {
  description = "Firehose S3 bucket buffer size"
}
variable "buffer_interval" {
  description = "Buffer incoming data for the specified period of time, in seconds, before delivering it to the destination."
}

# Cloudwatch
variable "firehose_cloudwatch_loggroup_name" {
  description = "Cloudwatch log group"
}
# Cloudwatch
variable "firehose_cloudwatch_logstream_name" {
  description = "Cloudwatch log stream"
}