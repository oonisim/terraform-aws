/*
variable "ecs_cluster_name" {
  description = "service"
}
*/
#--------------------------------------------------------------------------------
# ASG parameters
#--------------------------------------------------------------------------------
variable "asg_protect_from_scale_in" {
  #--------------------------------------------------------------------------------
  # When using ECS capacity provider managed termination protection, managed scaling must also be used otherwise managed termination protection will not work.
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/cluster-capacity-providers.html#capacity-providers-considerations
  # Otherwise Error:
  # error creating capacity provider: ClientException: The managed termination protection setting for the capacity provider is invalid.
  # To enable managed termination protection for a capacity provider, the Auto Scaling group must have instance protection from scale in enabled.
  #--------------------------------------------------------------------------------
  description = "(Optional) Allows setting instance protection. The autoscaling group will not select instances with this setting for terminination during scale in events."
  default = true
}

variable "asg_ecs_cluster_health_check_type" {
  description = "ASG instance health check. 'ELB' for service response, 'EC2' for if EC2 instance alive"
}

# Health Check Grace Period of the EC2 Auto Scaling Group.
# https://docs.aws.amazon.com/autoscaling/ec2/userguide/healthcheck.html#health-check-grace-period
#
# DO NOT confuse with ECS grace period. When using ECS, the ASG grace period should not matter,
# however, to be on the safe side, make sure to set the enough time for EC2 to startup.
# Seconds that ECS service scheduler should ignore ELB  health checks, container health checks.
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service_definition_parameters.html
variable "asg_ec2_health_check_grace_period" {
  description = "Seconds to wait before checking the health status of the EC2 instance."
}
/*
variable "asg_ecs_cluster_min_size" {
  description = "ASG min instance size"
}
variable "asg_ecs_cluster_max_size" {
  description = "ASG max instance size"
}
variable "asg_ecs_cluster_desired_capacity" {
  description = "ASG max instance desired capacity"
}
*/