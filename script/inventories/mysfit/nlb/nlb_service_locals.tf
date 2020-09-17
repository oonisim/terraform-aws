locals {
  #--------------------------------------------------------------------------------
  # ELB
  # TODO: Consider 1 to 1 and 1 to N relationshipo -> Need nlb module update
  # Currently expecting Listener - Target Group has 1 to 1 relationship.
  # Does not handndle 1 to many relationship in the nlb module.
  #--------------------------------------------------------------------------------
  nlb_listeners_for_ecs_service_ABC = [
    {
      port     = local.client_port_for_microservice_XYZ
      protocol = local.protocol_for_microservice_XYZ
      action   = "forward"
    },
  ]

  # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  # Define multiple target groups for a listner is not handled.
  # Define one target group for one listener.
  # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  nlb_target_groups_for_ecs_service_ABC = [
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
      # To limit the access from NLB, potential way is to use NLB IP address, IF NLB
      # Source IP Preservation is OFF, which requires IP target.
      #
      # [Source IP Preservation - AWS NLB document]
      # If you specify targets by IP address, the source IP addresses are the private IP addresses of the load balancer nodes.
      # If you specify targets using an instance ID, the source IP addresses of the clients are preserved and provided to your applications.
      # https://docs.aws.amazon.com/elasticloadbalancing/latest/network/load-balancer-target-groups.html#target-type
      # https://stackoverflow.com/questions/60431236/how-to-limit-the-access-to-ec2-from-nlb-only
      #--------------------------------------------------------------------------------
      # For auto scalaing group, the target_type is "instance" as ASG is adding instances.
      # Otherwise, will encounter. the Error creating AutoScaling Group:
      # ValidationError: Provided Target Group has invalid target type.
      # Please ensure all provided Target Groups have target type of instance.
      #--------------------------------------------------------------------------------

      #--------------------------------------------------------------------------------
      # Bridge mode does not support IP target type
      # [ERROR]
      # The provided target group arn:aws:elasticloadbalancing:$REGION:$ACCOUNT:targetgroup ... has target type ip,
      # which is incompatible with the bridge network mode specified in the task definition.
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
      # ECS/EC2 host port to expose
      #--------------------------------------------------------------------------------
      #port = 8080
      #protocol = "TCP"
      port       = local.ec2_host_port_for_microservice_XYZ
      protocol   = contains(local.NLB_PROTOCOLS, upper(local.protocol_for_microservice_XYZ)) ? local.protocol_for_microservice_XYZ : "NLB_INVALID_PROTOCOL_SPECIFIED"
      #--------------------------------------------------------------------------------
      stickiness = true
      tags       = {
        is_ecs_target = true
      }
    },
  ]
}
