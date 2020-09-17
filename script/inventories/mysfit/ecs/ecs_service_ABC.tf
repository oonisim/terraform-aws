# TODO: Seprate container configurations into ecs_task_container

locals {
  #--------------------------------------------------------------------------------
  # ECS does NOT support as of JUN2019) multiple target groups.
  # Hence ONLY ONE port mapping is effective as ELB forwards to one port with 1 TG.
  # PR https://github.com/aws/containers-roadmap/issues/12
  #--------------------------------------------------------------------------------

  # Container definition port mappings
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#container_definition_portmappings
  ecs_task_port_mappings = [
    {
      #"containerPort" = var.ecs_service_container_port
      "containerPort" = local.docker_container_port_for_microservice_XYZ

      #--------------------------------------------------------------------------------
      # NLB cannot use with dynamic port as in ECS tasks using dynamic ephemeral ports with failing health checks
      # https://forums.aws.amazon.com/message.jspa?messageID=805080
      # https://medium.com/@mohitshrestha02/understanding-dynamic-port-mapping-in-amazon-ecs-with-application-load-balancer-bf705ee0ca8e
      #--------------------------------------------------------------------------------
      #"hostPort" = var.ecs_service_host_port
      "hostPort" = local.ec2_host_port_for_microservice_XYZ
      #--------------------------------------------------------------------------------

      # protocol
      # Valid values are tcp and udp. The default is tcp.
      # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#container_definition_portmappings
      "protocol" = "tcp"
    }
  ]
}

module "ecs_service_ABC" {
  source = "../../../modules/ecs_service"

  PROJECT = var.PROJECT
  ENV     = var.ENV
  REGION  = var.REGION

  #--------------------------------------------------------------------------------
  # ECS cluster
  #--------------------------------------------------------------------------------
  ecs_cluster_id = aws_ecs_cluster.this.id

  #--------------------------------------------------------------------------------
  # ECS service
  #--------------------------------------------------------------------------------
  ecs_service_name          = local.ecs_service_ABC_name
  ecs_service_launch_type   = var.ecs_service_launch_type

  #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  # WARNING! This paramter is for creation time only.
  # So as to ignore any changes to that count caused externally (e.g. Application Autoscaling).
  # This will allow external changes without Terraform plan difference.
  # https://www.terraform.io/docs/providers/aws/r/ecs_service.html#ignoring-changes-to-desired-count
  #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  ecs_service_desired_count = local.ecs_task_ABC_desired_count

  #--------------------------------------------------------------------------------
  # Duration to ignore ELB health check
  # https://aws.amazon.com/premiumsupport/knowledge-center/elb-ecs-tasks-improperly-replaced/
  # https://stackoverflow.com/questions/60085717/is-aws-nlb-supported-for-ecs
  #--------------------------------------------------------------------------------
  # TODO: use the ecs_service_ABC_healthcheck_grece_period global parameter
  #ecs_healthcheck_grace_period_seconds = var.ecs_healthcheck_grace_period_seconds
  ecs_healthcheck_grace_period_seconds = local.ecs_service_ABC_healthcheck_grece_period
  #--------------------------------------------------------------------------------
  # NLB cannot use with dynamic port as in ECS tasks using dynamic ephemeral ports with failing health checks
  # https://forums.aws.amazon.com/message.jspa?messageID=805080
  # https://medium.com/@mohitshrestha02/understanding-dynamic-port-mapping-in-amazon-ecs-with-application-load-balancer-bf705ee0ca8e
  #--------------------------------------------------------------------------------

  #--------------------------------------------------------------------------------
  # LB (Use the first TG in the LB Target Groups as the ECS service LB.
  # TODO: Should use better way to identify the TG to use.
  #
  # TODO: Incorporate the PR of multiple ELB target groups
  # ECS does not support (as of JUN2019) multiple target groups.
  # PR https://github.com/aws/containers-roadmap/issues/12
  # [Update]
  # Issue fixed as in https://aws.amazon.com/about-aws/whats-new/2019/07/amazon-ecs-services-now-support-multiple-load-balancer-target-groups/
  #--------------------------------------------------------------------------------
  elb_target_group_arn = local.lb_target_group_arns[0]


  #================================================================================
  # ECS task definition
  # TODO: Move ecs_task from module to ecs_task module and use it from an ecs_task component in the inventory
  #================================================================================
  #--------------------------------------------------------------------------------
  # TODO: Move ecs_task from module to ecs_task module and use it from an ecs_task component in the inventory
  # Each docker container defintion and their task definition is service specific, not common among servicce.
  # Only common configurations should go to TF module.
  #--------------------------------------------------------------------------------
  ecs_task_name          = local.ecs_service_ABC_name
  ecs_task_port_mappings = local.ecs_task_port_mappings
  ecs_task_network_mode  = local.ecs_task_ABC_network_mode

  #--------------------------------------------------------------------------------
  # Container (microservice)
  # ECS currently support single LB target group. Hence single service/port per container.
  #--------------------------------------------------------------------------------
  container_image_url = local.container_image_registry_XYZ_url
  container_name      = local.microservice_XYZ_name
  # TODO: replace with global parameter
  #container_service_port      = var.ecs_service_container_port
  container_port      = local.docker_container_port_for_microservice_XYZ

}
