variable "PROJECT" {
}

variable "ENV" {
}

variable "REGION" {
}

variable "name" {
  type        = string
  description = "DynamoDB tableName"
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `namespace`, `stage`, `name`, and `attributes`"
}

variable "hash_key" {
  type        = string
  description = "DynamoDB table Hash Key"
}

variable "range_key" {
  type        = string
  default     = ""
  description = "DynamoDB table Range Key"
}

variable "attributes" {
  type        = list(string)
  default     = []
  description = "Additional attributes (e.g. `policy` or `role`)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)"
}

variable "billing_mode" {
  description = "(Optional) Controls how you are charged for read and write throughput and how you manage capacity. The valid values are PROVISIONED and PAY_PER_REQUEST. Defaults to PROVISIONED."
  type        = string
  default     = "PROVISIONED"
}
variable "autoscale_write_target" {
  default     = 50
  description = "The target value (in %) for DynamoDB write autoscaling"
}

variable "autoscale_read_target" {
  default     = 50
  description = "The target value (in %) for DynamoDB read autoscaling"
}

variable "autoscale_min_read_capacity" {
  default     = 5
  description = "DynamoDB autoscaling min read capacity"
}

variable "autoscale_max_read_capacity" {
  default     = 20
  description = "DynamoDB autoscaling max read capacity"
}

variable "autoscale_min_write_capacity" {
  default     = 5
  description = "DynamoDB autoscaling min write capacity"
}

variable "autoscale_max_write_capacity" {
  default     = 20
  description = "DynamoDB autoscaling max write capacity"
}

variable "enable_streams" {
  type        = bool
  default     = false
  description = "Enable DynamoDB streams"
}

variable "stream_view_type" {
  type        = string
  default     = ""
  description = "When an item in the table is modified, what information is written to the stream"
}

variable "enable_encryption" {
  type        = string
  default     = "true"
  description = "Enable DynamoDB server-side encryption"
}

variable "enable_point_in_time_recovery" {
  type        = string
  default     = "true"
  description = "Enable DynamoDB point in time recovery"
}

variable "enable_ttl" {
  type    = string
  default = false
}

variable "ttl_attribute" {
  type        = string
  default     = "Expires"
  description = "DynamoDB table TTL attribute"
}

variable "enable_autoscaler" {
  type        = string
  default     = "true"
  description = "Flag to enable/disable DynamoDB autoscaling"
}

variable "dynamodb_attributes" {
  type        = list(map(string))
  default     = []
  description = "Additional DynamoDB attributes in the form of a list of mapped values"
}

variable "global_secondary_index_map" {
  type = list(object({
    name            = string
    hash_key        = string
    range_key       = string
    projection_type = string
    #--------------------------------------------------------------------------------
    # Github issue #3828 global secondary index always recreated
    # https://github.com/terraform-providers/terraform-provider-aws/issues/3828
    #--------------------------------------------------------------------------------
    non_key_attributes = list(string)
    write_capacity  = number
    read_capacity   = number
  }))
  default     = []
  description = "Additional global secondary indexes in the form of a list of mapped values"
}


variable "local_secondary_index_map" {
  #  type        = list(map(string))
  default     = []
  description = "Additional local secondary indexes in the form of a list of mapped values"
}
