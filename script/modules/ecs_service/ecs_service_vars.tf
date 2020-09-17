#--------------------------------------------------------------------------------
# ECS
#--------------------------------------------------------------------------------
variable "ecs_cluster_id" {
  description = "ECS cluster ID for the service to attend. The EC2 instance must join the cluster via Userdata"
  type = string
}
variable "ecs_service_name" {
  description = "Identifier name of the ECS service"
  type = string
}
variable "ecs_service_launch_type" {
  description = "How ECS launch instances. EC2 or FARGATE"
  type = string
  default = "EC2"
}

variable "ecs_service_desired_count" {
  #--------------------------------------------------------------------------------
  # WARNING! This paramter is for creation time only.
  # So as to ignore any changes to that count caused externally (e.g. Application Autoscaling).
  # This will allow external changes without Terraform plan difference.
  # https://www.terraform.io/docs/providers/aws/r/ecs_service.html#ignoring-changes-to-desired-count
  #--------------------------------------------------------------------------------

  #--------------------------------------------------------------------------------
  # The number of instantiations of the specified task definition (=docker image) running.
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service_definition_parameters.html
  #--------------------------------------------------------------------------------
  description = "The number of containers to run for the service."
}
variable "ecs_service_scheduling_strategy" {
  type = string
  default = "REPLICA"
}

#--------------------------------------------------------------------------------
# For the awsvpc network mode to receive their own Elastic Network Interface.
# Not required/supported for other network modes.
#--------------------------------------------------------------------------------
/*
variable "ecs_service_awsvpc_network_subnet_ids" {
  description = "awsvpc network mode subnet IDs in which ECS tasks are to be placed"
  type = list
}
variable "ecs_service_awsvpc_network_sg_ids" {
  description = "awsvpc network mode security Group IDs to attach to ECS/EC2"
  type = list
}
variable "ecs_service_awsvpc_network_assign_public_ip" {
  description = "awsvpc network mode & Fargate only - if assign public IP to ECS/EC2"
  type = bool
  default = false
}
*/

#--------------------------------------------------------------------------------
# ELB for ECS to register/deregister.
# [Clarification]
# Is this required when not using Fargate?
#--------------------------------------------------------------------------------
variable "elb_target_group_arn" {
  description = "Load balancer target group which forwards "
}

variable "ecs_healthcheck_grace_period_seconds" {
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown"
  default = 60
}