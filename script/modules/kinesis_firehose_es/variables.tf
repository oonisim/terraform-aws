variable "PROJECT" {
  type = string
}
variable "ENV" {
  type = string
}

# Kinesis firehowe
variable "name" {
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

# ElasticSearch
variable "es_domain_arn" {}
variable "es_index_name" {}
variable "es_type_name" {
  description = "The document class (Type) to store in the ES index"
}

# Cloudwatch
variable "cloudwatch_loggroup_name" {
  description = "Cloudwatch log group"
}
