variable "PROJECT" {
  default = "TBD"
}
variable "ENV" {
  default = "TBD"
}
variable "REGION" {
  default = "TBD"
}

#--------------------------------------------------------------------------------
# S3 bucket
# - To presign to upload the project data.
# - To upload packages e.g. lambda function packages
#--------------------------------------------------------------------------------
variable "bucket" {
  description = "TBD"
  default = "TBD"
}

#--------------------------------------------------------------------------------
# Kinesis stream
#--------------------------------------------------------------------------------
variable "kinesis_stream_name" {
  description = "Kinesis stream name"
}

variable "sns_topic_name" {
  description = "SNS topic"
}