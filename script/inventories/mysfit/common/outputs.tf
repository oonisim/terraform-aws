#================================================================================
# Constants
#================================================================================
output "ELB_TYPES" {
  value = var.ELB_TYPES
}
output "ELB_TYPE_ALB" {
  value = var.ELB_TYPE_ALB
}
output "ELB_TYPE_NLB" {
  value = var.ELB_TYPE_NLB
}
output "NLB_PROTOCOLS" {
  value = var.NLB_PROTOCOLS
}
output "ALB_PROTOCOLS" {
  value = var.ALB_PROTOCOLS
}
output "DOCKER_EPHEMERAL_FROM_PORT" {
  value = var.DOCKER_EPHEMERAL_FROM_PORT
}
output "DOCKER_EPHEMERAL_TO_PORT" {
  value = var.DOCKER_EPHEMERAL_TO_PORT
}

#================================================================================
# ECS Cluster
#================================================================================
output "ecs_cluster_name" {
  value = var.ecs_cluster_name
}

#----------------------------------------------------------------------
# Cluster (EC2) auto-scaling
# https://www.terraform.io/docs/providers/aws/r/ecs_capacity_provider.html
#----------------------------------------------------------------------
output "enable_ecs_cluster_auto_scaling" {
  value = var.enable_ecs_cluster_auto_scaling
}
output "ecs_cluster_autoscaling_min_size" {
  value = var.ecs_cluster_autoscaling_min_size
}
output "ecs_cluster_autoscaling_max_size" {
  value = var.ecs_cluster_autoscaling_max_size
}
output "ecs_cluster_autoscaling_target_capacity" {
  value = var.ecs_cluster_autoscaling_target_capacity
}
output "ecs_cluster_autoscaling_min_step_size" {
  value = var.ecs_cluster_autoscaling_min_step_size
}
output "ecs_cluster_autoscaling_max_step_size" {
  value = var.ecs_cluster_autoscaling_max_step_size
}
output "ecs_cluster_autoscaling_service_linked_role_arn" {
  value = local.ecs_cluster_autoscaling_service_linked_role_arn
}

#----------------------------------------------------------------------
# ECS Service
#----------------------------------------------------------------------
output "ecs_service_ABC_name" {
  value = var.ecs_service_ABC_name
}
output "ecs_service_ABC_healthcheck_grece_period" {
  description = "ECS service healthcheck grace period in seconds"
  value = var.ecs_service_ABC_healthcheck_grece_period
}
output "ecs_task_ABC_network_mode" {
  value = var.ecs_task_ABC_network_mode
}
output "elb_target_type_for_ecs_task_ABC" {
  value = local.elb_target_type_for_ecs_task_ABC  # NOTE the value is local, not var
}

output "ENABLE_ECS_EC2_CONNECTION_DEBUG" {
  value = var.ENABLE_ECS_EC2_CONNECTION_DEBUG
}

#----------------------------------------------------------------------
# Microservices of the ECS service
#----------------------------------------------------------------------
output "microservice_XYZ_name" {
  value = var.microservice_XYZ_name
}
output "ecs_task_ABC_desired_count" {
  value = var.ecs_task_ABC_desired_count
}
output "protocol_for_microservice_XYZ" {
  value = var.protocol_for_microservice_XYZ
}
output "client_port_for_microservice_XYZ" {
  value = var.client_port_for_microservice_XYZ
}

output "ec2_host_port_for_microservice_XYZ" {
  value = var.ec2_host_port_for_microservice_XYZ
}
output "docker_container_port_for_microservice_XYZ" {
  value = var.docker_container_port_for_microservice_XYZ
}

#================================================================================
# ELB
#================================================================================

#--------------------------------------------------------------------------------
# Utility outputs to avoid coding condition logic elsewhere.
#--------------------------------------------------------------------------------
output "elb_type_for_microservice_XYZ" {
  value = contains(list("HTTP", "HTTPS"), upper(var.protocol_for_microservice_XYZ)) ? "application" : "network"
}
output "elb_protocol_for_microservice_XYZ" {
  value = var.protocol_for_microservice_XYZ
}

#--------------------------------------------------------------------------------
# ALB SG (NLB has no SG)
#--------------------------------------------------------------------------------
output "ingress_cidr_blocks_at_elb_for_service_ABC" {
  value = var.ingress_cidr_blocks_at_elb_for_service_ABC
}

#================================================================================
# Docker registry
#================================================================================
output "docker_registry_host" {
  value = local.docker_registry_host
}
output "docker_registry_port" {
  value = local.docker_registry_port
}
