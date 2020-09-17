variable "PROJECT" {
  type = string
}
variable "ENV" {
  type = string
}

# VPC
variable "vpc_id" {}
variable "subnet_id" {}

variable "ingress_cidr_blocks" {
  type = list
}

# EC2
variable "name" {}
variable "instance_type" {}
variable "keypair_public_key" {}

# Root volume
variable "root_volume_size" {}
variable "root_volume_type" {}

# Block device
variable "ebs_size" {}

variable "firehose_name" {
  description = "Kinesis firehose name to specify to the Kinesis Firehose Agent"
}

# S3
variable "bucket_name" {
}

# Cloudwatch
variable "cloudwatch_loggroup_name" {

}