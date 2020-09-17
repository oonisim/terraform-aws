#--------------------------------------------------------------------------------
# ECS service configuations
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service_definition_parameters.html
#--------------------------------------------------------------------------------
resource "aws_ecs_service" "this" {
  name                = "${var.PROJECT}_${var.ENV}_${var.ecs_service_name}"
  cluster             = var.ecs_cluster_id
  task_definition     = aws_ecs_task_definition.this.arn

  scheduling_strategy = var.ecs_service_scheduling_strategy
  launch_type         = var.ecs_service_launch_type
  desired_count       = var.ecs_service_desired_count

  #--------------------------------------------------------------------------------
  # healthCheckGracePeriodSeconds
  # Seconds that ECS service scheduler should ignore ELB  health checks, container health checks,
  # and Route 53 health checks after a task enters a RUNNING state.
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service_definition_parameters.html
  #--------------------------------------------------------------------------------
  health_check_grace_period_seconds = var.ecs_healthcheck_grace_period_seconds

  /*
  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.ami-id != 'ami-fake'"
  }
  */

  #--------------------------------------------------------------------------------
  # Prior to the introduction of a service-linked role for ECS, you were required to create
  # an IAM role for ECS services which granted ECS the permission it needed.
  # This role is no longer required, however it is available if needed.
  # For more information, see Legacy IAM Roles for Amazon ECS.
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using-service-linked-roles.html
  #
  # Make sure to create the service linked role if not created yet.
  # https://docs.aws.amazon.com/cli/latest/reference/iam/create-service-linked-role.html
  # https://www.terraform.io/docs/providers/aws/r/iam_service_linked_role.html
  # $ aws iam create-service-linked-role --aws-service-name ecs.amazonaws.com
  #--------------------------------------------------------------------------------
  #iam_role            = aws_iam_role.ecs_service.arn
  iam_role            = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS"
  #--------------------------------------------------------------------------------

  load_balancer {
    target_group_arn  = var.elb_target_group_arn

    #--------------------------------------------------------------------------------
    # Container internal port (not the EC2 port). ECS looks into the port mapping.
    #--------------------------------------------------------------------------------
    container_port    = var.container_port
    container_name    = var.container_name
  }

  #--------------------------------------------------------------------------------
  # Which subnet ECS/EC2 is to be placed is up to ASG.
  #--------------------------------------------------------------------------------

  #--------------------------------------------------------------------------------
  # For the awsvpc network mode to receive their own Elastic Network Interface.
  # Not required/supported for other network modes.
  #--------------------------------------------------------------------------------
  /* Disabled as awsvpc mode is not considered yet
  network_configuration {
    assign_public_ip = var.ecs_service_awsvpc_network_assign_public_ip
    security_groups  = var.ecs_service_awsvpc_network_sg_ids
    subnets          = var.ecs_service_awsvpc_network_subnet_ids
  }
  */

  lifecycle {
    #--------------------------------------------------------------------------------
    # To ignore any changes to that count caused externally (e.g. Application Autoscaling).
    # This will allow external changes without Terraform plan difference
    # https://www.terraform.io/docs/providers/aws/r/ecs_service.html#ignoring-changes-to-desired-count
    #--------------------------------------------------------------------------------
    ignore_changes = [
      desired_count
    ]
  }

  depends_on = [
    aws_iam_role.ecs_service,
    aws_iam_role_policy_attachment.ecs_service
  ]
}
