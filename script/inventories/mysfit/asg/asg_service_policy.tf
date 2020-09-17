#--------------------------------------------------------------------------------
# Variables
#--------------------------------------------------------------------------------
variable "scaling_adjustment" {
  description = "EC2 AMI ID"
  type = string
  default = 1
}
variable "cooldown_period" {
  description = "The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start."
  type = string
  default = 180
}

#--------------------------------------------------------------------------------
# Resources
#--------------------------------------------------------------------------------
resource "aws_autoscaling_policy" "scaleup" {
  name = "${var.PROJECT}_${var.ENV}_${local.ecs_cluster_name}_scaleup"
  autoscaling_group_name = local.asg_ecs_cluster_name

  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = var.scaling_adjustment
  cooldown = var.cooldown_period
}

resource "aws_cloudwatch_metric_alarm" "cpuhigh" {
  alarm_name = "${var.PROJECT}_${var.ENV}_${local.ecs_cluster_name}_alarm_cpuhigh"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "60"

  dimensions = {
    AutoScalingGroupName = local.asg_ecs_cluster_name
  }

  alarm_description = "This metric monitor EC2 instance cpu utilization"
  alarm_actions = [
    "${aws_autoscaling_policy.scaleup.arn}"
  ]
}

resource "aws_autoscaling_policy" "scaledown" {
  name = "${var.PROJECT}_${var.ENV}_${local.ecs_cluster_name}_scaledown"
  autoscaling_group_name = local.asg_ecs_cluster_name

  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = var.scaling_adjustment * -1
  cooldown = var.cooldown_period
}

resource "aws_cloudwatch_metric_alarm" "cpulow" {
  alarm_name = "${var.PROJECT}_${var.ENV}_${local.ecs_cluster_name}_alarm_cpulow"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "10"

  dimensions = {
    AutoScalingGroupName = local.asg_ecs_cluster_name
  }

  alarm_description = "This metric monitor EC2 instance cpu utilization"
  alarm_actions = [
    "${aws_autoscaling_policy.scaledown.arn}"
  ]
}

