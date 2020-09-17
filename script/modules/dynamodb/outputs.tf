output "name" {
  value = aws_dynamodb_table.this.name
}

output "arn" {
  value = aws_dynamodb_table.this.arn
}

output "id" {
  value = aws_dynamodb_table.this.id
}

output "hash_key" {
  value = aws_dynamodb_table.this.hash_key
}

output "range_key" {
  value = var.range_key
}

output "region" {
  value = var.REGION
}

output "stream_arn" {
  value = aws_dynamodb_table.this.stream_enabled? aws_dynamodb_table.this.stream_arn : "NA_AS_STREAM_NOT_ENABLED"
}
output "stream_view_type" {
  value = aws_dynamodb_table.this.stream_enabled? aws_dynamodb_table.this.stream_view_type : "NA_AS_STREAM_NOT_ENABLED"
}
# The combination of AWS customer ID, DynamoDB table name and stream_label is guaranteed to be unique.
# It can be used for creating CloudWatch Alarms.
output "stream_label" {
  value = aws_dynamodb_table.this.stream_enabled? aws_dynamodb_table.this.stream_label : "NA_AS_STREAM_NOT_ENABLED"
}