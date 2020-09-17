variable "name" {
  type        = string
  description = "DynamoDB tableName"
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
  type = list(object({
    name = string
    type = string
  }))
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
}
