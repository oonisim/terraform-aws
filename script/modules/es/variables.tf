variable "PROJECT" {
  type = string
}
variable "ENV" {
  type = string
}

variable "name" {
  description = "ElasticSearch domain name"
}

variable "es_elasticsearch_version" {}
# https://aws.amazon.com/elasticsearch-service/pricing/
variable "es_instance_count" {}
variable "es_instance_type" {}
variable "es_dedicated_master_threshold" {}
variable "es_dedicated_master_type" {}
variable "es_zone_awareness" {}
variable "es_ebs_volume_size" {}
variable "es_ebs_volume_type" {}

# ES IAM allowed IP ranges
variable "es_source_ips" {
  type = list
  description = "List of IP and CIDR from which access to ES is allowed"
}
# Cloudwatch
variable "cloudwatch_loggroup_name" {
}

