data "aws_availability_zones" "all" {
}

data "aws_region" "current" {
}

# https://www.terraform.io/docs/providers/aws/d/caller_identity.html
data "aws_caller_identity" "current" {
}

data "aws_cloudwatch_log_group" "this" {
  name = "${var.cloudwatch_loggroup_name}"
}

locals {
  cloudwatch_loggroup_arn = "${data.aws_cloudwatch_log_group.this.arn}"
}