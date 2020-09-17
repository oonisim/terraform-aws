#----------------------------------------------------------------------
# Common/Global
#----------------------------------------------------------------------
locals {
  #----------------------------------------------------------------------
  # Constants
  #----------------------------------------------------------------------
  ELB_TYPES                  = data.terraform_remote_state.common.outputs.ELB_TYPES
  ELB_TYPE_ALB               = data.terraform_remote_state.common.outputs.ELB_TYPE_ALB
  ELB_TYPE_NLB               = data.terraform_remote_state.common.outputs.ELB_TYPE_NLB
  ALB_PROTOCOLS              = data.terraform_remote_state.common.outputs.ALB_PROTOCOLS
  NLB_PROTOCOLS              = data.terraform_remote_state.common.outputs.NLB_PROTOCOLS
  DOCKER_EPHEMERAL_FROM_PORT = data.terraform_remote_state.common.outputs.DOCKER_EPHEMERAL_FROM_PORT
  DOCKER_EPHEMERAL_TO_PORT   = data.terraform_remote_state.common.outputs.DOCKER_EPHEMERAL_TO_PORT

  #----------------------------------------------------------------------
  # Debug
  #----------------------------------------------------------------------
  ENABLE_ECS_EC2_CONNECTION_DEBUG = data.terraform_remote_state.common.outputs.ENABLE_ECS_EC2_CONNECTION_DEBUG

  #----------------------------------------------------------------------
  # ECS
  #----------------------------------------------------------------------
  ecs_cluster_name = data.terraform_remote_state.common.outputs.ecs_cluster_name

  #----------------------------------------------------------------------
  # Cluster (EC2) auto-scaling
  # https://www.terraform.io/docs/providers/aws/r/ecs_capacity_provider.html
  #----------------------------------------------------------------------
  enable_ecs_cluster_auto_scaling                 = data.terraform_remote_state.common.outputs.enable_ecs_cluster_auto_scaling
  ecs_cluster_autoscaling_service_linked_role_arn = data.terraform_remote_state.common.outputs.ecs_cluster_autoscaling_service_linked_role_arn
  ecs_cluster_autoscaling_min_size                = data.terraform_remote_state.common.outputs.ecs_cluster_autoscaling_min_size
  ecs_cluster_autoscaling_max_size                = data.terraform_remote_state.common.outputs.ecs_cluster_autoscaling_max_size
  ecs_cluster_autoscaling_min_step_size           = data.terraform_remote_state.common.outputs.ecs_cluster_autoscaling_min_step_size
  ecs_cluster_autoscaling_max_step_size           = data.terraform_remote_state.common.outputs.ecs_cluster_autoscaling_max_step_size
  ecs_cluster_autoscaling_target_capacity         = data.terraform_remote_state.common.outputs.ecs_cluster_autoscaling_target_capacity

  #----------------------------------------------------------------------
  # ECS Service ABC
  #----------------------------------------------------------------------
  ecs_service_ABC_name                     = data.terraform_remote_state.common.outputs.ecs_service_ABC_name
  ecs_service_ABC_healthcheck_grece_period = data.terraform_remote_state.common.outputs.ecs_service_ABC_healthcheck_grece_period

  #----------------------------------------------------------------------
  # ECS Task for ECS Service
  #----------------------------------------------------------------------
  ecs_task_ABC_network_mode        = data.terraform_remote_state.common.outputs.ecs_task_ABC_network_mode
  elb_target_type_for_ecs_task_ABC = data.terraform_remote_state.common.outputs.elb_target_type_for_ecs_task_ABC

  #----------------------------------------------------------------------
  # microservice XYZ
  #----------------------------------------------------------------------
  microservice_XYZ_name                      = data.terraform_remote_state.common.outputs.microservice_XYZ_name
  ecs_task_ABC_desired_count                 = data.terraform_remote_state.common.outputs.ecs_task_ABC_desired_count
  client_port_for_microservice_XYZ           = data.terraform_remote_state.common.outputs.client_port_for_microservice_XYZ
  protocol_for_microservice_XYZ              = data.terraform_remote_state.common.outputs.protocol_for_microservice_XYZ
  ec2_host_port_for_microservice_XYZ         = data.terraform_remote_state.common.outputs.ec2_host_port_for_microservice_XYZ
  docker_container_port_for_microservice_XYZ = data.terraform_remote_state.common.outputs.docker_container_port_for_microservice_XYZ
  ingress_cidr_blocks_at_elb_for_service_ABC = data.terraform_remote_state.common.outputs.ingress_cidr_blocks_at_elb_for_service_ABC
}
