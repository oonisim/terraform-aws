resource "aws_cloudwatch_log_group" "ecs" {
  name = "/${var.PROJECT}/${var.ENV}/ecs"
  retention_in_days = var.lg_ecs_retention_in_days

  tags = {
    Project = var.PROJECT
    Environment = var.ENV
  }
}

output "cloudwatch_lg_ecs_arn" {
  value = "${aws_cloudwatch_log_group.ecs.arn}"
}