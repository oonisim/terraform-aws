resource "aws_cloudwatch_log_group" "this" {
  count = var.loggroup_name != null ? 1 : 0
  name  = "${var.PROJECT}_${var.ENV}_${var.loggroup_name}"
}

resource "aws_cloudwatch_log_stream" "this" {
  count          = var.logsteram_name == null ? 0: 1
  name           = "${var.PROJECT}_${var.ENV}_${var.logsteram_name}"
  log_group_name = aws_cloudwatch_log_group.this[0].name
}