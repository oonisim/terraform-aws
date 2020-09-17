output "cloudwatch_loggroup_arn" {
  value = var.loggroup_name != null ? aws_cloudwatch_log_group.this[0].arn : null
}
output "cloudwatch_loggroup_name" {
  value = var.loggroup_name != null ? aws_cloudwatch_log_group.this[0].name : null
}
output "cloudwatch_logstream_arn" {
  value = var.logsteram_name != null ? aws_cloudwatch_log_stream.this[0].arn : null
}
output "cloudwatch_logstream_name" {
  value = var.logsteram_name != null ? aws_cloudwatch_log_stream.this[0].name: null
}
