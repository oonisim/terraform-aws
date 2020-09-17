locals {
  #--------------------------------------------------------------------------------
  # ALB
  # TODO: Consider 1 to 1 and 1 to N relationshipo -> Need alb module update
  # Currently expecting Listener - Target Group has 1 to 1 relationship.
  # Does not handndle 1 to many relationship in the nlb module.
  #--------------------------------------------------------------------------------
  #--------------------------------------------------------------------------------
  alb_listeners_for_ecs_service_ABC = [
    { port     = local.client_port_for_microservice_XYZ
      protocol = local.protocol_for_microservice_XYZ
      action = "forward"
    },
  ]

  #--------------------------------------------------------------------------------
  # ALB listener target group
  #--------------------------------------------------------------------------------
  # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  # Define multiple target groups for a listner is not handled.
  # Define one target group for one listener.
  # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  alb_target_groups_for_ecs_service_ABC = [
    {
      #--------------------------------------------------------------------------------
      # Unique name of the target group (max 6 in length).
      # Name is used to identify the target group and set to the name_prefix to avoid
      # the TF issue of "resource already exists".
      # Max length is 6 due to the TF limitation.
      # https://www.terraform.io/docs/providers/aws/r/lb_target_group.html#name_prefix
      #--------------------------------------------------------------------------------
      # TODO: Set the name from micro service name defined in common.
      name = "${var.PROJECT}-${var.ENV}-target-group-ecs-service-${local.microservice_XYZ_name}"

      #--------------------------------------------------------------------------------
      # For auto scalaing group, the target_type is "instance" as ASG is adding instances.
      # Otherwise, will encounter. the Error creating AutoScaling Group:
      # ValidationError: Provided Target Group has invalid target type.
      # Please ensure all provided Target Groups have target type of instance.
      #--------------------------------------------------------------------------------

      #--------------------------------------------------------------------------------
      # target type ip is incompatible with the bridge network mode specified in the task definition
      # https://github.com/hashicorp/terraform/issues/24266
      # https://github.com/terraform-providers/terraform-provider-aws/issues/12252
      #--------------------------------------------------------------------------------
      #target_type = "ip"       # target_type IP has an issue with docker briddge network mode.
      target_type = local.elb_target_type_for_ecs_task_ABC
      #--------------------------------------------------------------------------------

      #--------------------------------------------------------------------------------
      # TODO: Those values need to come from common
      #--------------------------------------------------------------------------------
      #port = 80
      #protocol = "HTTP"
      port = local.ec2_host_port_for_microservice_XYZ
      protocol = contains(local.ALB_PROTOCOLS, upper(local.protocol_for_microservice_XYZ)) ? local.protocol_for_microservice_XYZ : "ALB_INVALID_PROTOCOL_SPECIFIED"
      #--------------------------------------------------------------------------------

      #--------------------------------------------------------------------------------
      # Always use stickiness and hard-coded in alb.tf in alb module.
      #stickiness = true
      #--------------------------------------------------------------------------------
    },
  ]
}