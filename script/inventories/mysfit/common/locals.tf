locals {
  #----------------------------------------------------------------------
  # Autoscaling service linked role
  #
  # https://docs.amazonaws.cn/en_us/autoscaling/application/userguide/application-auto-scaling-service-linked-roles.html#create-service-linked-role-automatic
  #----------------------------------------------------------------------
  ecs_cluster_autoscaling_service_linked_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
}

locals {
  #----------------------------------------------------------------------
  # Amazon ECR Registries
  # https://docs.aws.amazon.com/AmazonECR/latest/userguide/Registries.html
  #----------------------------------------------------------------------
  docker_registry_host = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.id}.amazonaws.com"
  docker_registry_port = 443
}

#--------------------------------------------------------------------------------
# ELB target type for the ECS task
# Because ECS Task level "network_mode" (which applies to all the containers)
# restricts the target type of ELB, define the default value.
#--------------------------------------------------------------------------------
locals {
  # Fallback default value is "instance"
  elb_target_type_for_ecs_task_ABC = var.ecs_task_ABC_network_mode == "awsbpc" ? "ip" : var.ecs_task_ABC_network_mode == "bridge" ? "instance" : "instance"
}
