variable "dynamodb_table_name" {
  type        = string
  description = "DynamoDB tableName"
}
variable "dynamodb_table_hash_key" {
  type        = string
  description = "DynamoDB table Hash Key"
}

variable "dynamodb_table_enable_streams" {
  type        = bool
  description = "Enable DynamoDB streams"
}
variable "dynamodb_table_stream_view_type" {
  type        = string
  description = "When an item in the table is modified, what information is written to the stream"
}

variable "dynamodb_table_global_secondary_index_map" {
  type = list
}
