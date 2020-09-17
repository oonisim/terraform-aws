#----------------------------------------------------------------------
# Common/Global
#----------------------------------------------------------------------
locals {
  #----------------------------------------------------------------------
  # Constants
  #----------------------------------------------------------------------
  ELB_TYPES     = data.terraform_remote_state.common.outputs.ELB_TYPES
  ELB_TYPE_ALB  = data.terraform_remote_state.common.outputs.ELB_TYPE_ALB
  ELB_TYPE_NLB  = data.terraform_remote_state.common.outputs.ELB_TYPE_NLB
  ALB_PROTOCOLS = data.terraform_remote_state.common.outputs.ALB_PROTOCOLS
  NLB_PROTOCOLS = data.terraform_remote_state.common.outputs.NLB_PROTOCOLS

  #----------------------------------------------------------------------
  # ECS
  #----------------------------------------------------------------------
  #ecs_cluster_name = data.terraform_remote_state.common.outputs.ecs_cluster_name

  #----------------------------------------------------------------------
  # Cluster (EC2) auto-scaling
  # https://www.terraform.io/docs/providers/aws/r/ecs_capacity_provider.html
  #----------------------------------------------------------------------
  enable_ecs_cluster_auto_scaling         = data.terraform_remote_state.common.outputs.enable_ecs_cluster_auto_scaling
  ecs_cluster_autoscaling_min_step_size   = data.terraform_remote_state.common.outputs.ecs_cluster_autoscaling_min_step_size
  ecs_cluster_autoscaling_max_step_size   = data.terraform_remote_state.common.outputs.ecs_cluster_autoscaling_max_step_size
  ecs_cluster_autoscaling_target_capacity = data.terraform_remote_state.common.outputs.ecs_cluster_autoscaling_target_capacity

  #----------------------------------------------------------------------
  # ECS service XYZ
  #----------------------------------------------------------------------
  microservice_XYZ_name                         = data.terraform_remote_state.common.outputs.microservice_XYZ_name
  ecs_task_ABC_desired_count                = data.terraform_remote_state.common.outputs.ecs_task_ABC_desired_count
  client_port_for_microservice_XYZ                         = data.terraform_remote_state.common.outputs.client_port_for_microservice_XYZ
  protocol_for_microservice_XYZ                     = data.terraform_remote_state.common.outputs.protocol_for_microservice_XYZ
  ec2_host_port_for_microservice_XYZ                = data.terraform_remote_state.common.outputs.ec2_host_port_for_microservice_XYZ
  docker_container_port_for_microservice_XYZ        = data.terraform_remote_state.common.outputs.docker_container_port_for_microservice_XYZ
  ecs_service_ABC_healthcheck_grece_period = data.terraform_remote_state.common.outputs.ecs_service_ABC_healthcheck_grece_period
}
