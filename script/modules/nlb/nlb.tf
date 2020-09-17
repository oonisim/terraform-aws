locals {
  #--------------------------------------------------------------------------------
  # For ELB target port, when 0 is passed when dynamic port mapping is used, then specify dummpy port.
  # Use Echo service default port
  #--------------------------------------------------------------------------------
  DUMMY_PORT_FOR_DYNAMIC_MAPPING = 7  # Echo service
  #DUMMY_PORT_FOR_DYNAMIC_MAPPING = 22
  #--------------------------------------------------------------------------------
}

resource "aws_lb" "this" {
  load_balancer_type = "network"
  name               = replace("${var.PROJECT}-${var.ENV}-${var.name}", "/[_.]/", "-")
  internal           = false

  #--------------------------------------------------------------------------------
  # Need to be in a subnet with internet access
  #--------------------------------------------------------------------------------
  subnets            = flatten(["${var.subnet_ids}"])

  #--------------------------------------------------------------------------------
  # Feb 22, 2018
  # https://aws.amazon.com/about-aws/whats-new/2018/02/network-load-balancer-now-supports-cross-zone-load-balancing/
  # NLB now distribute requests regardless of AZ with cross-zone load balancing.
  # As previously there is no cross zone for NLB, by default it is disabled (to be backward compatible?)
  #--------------------------------------------------------------------------------
  enable_cross_zone_load_balancing = true

  #--------------------------------------------------------------------------------
  # NLB does not have SG. Use NACL or SG on target instances.
  #--------------------------------------------------------------------------------

  access_logs {
    bucket  = var.bucket_log_name
    prefix  = "${var.PROJECT}-${var.ENV}-${var.name}"
    #--------------------------------------------------------------------------------
    # NLB access logs are created ONLY for a TLS listener and about TLS requests.
    # https://docs.aws.amazon.com/elasticloadbalancing/latest/network/load-balancer-access-logs.html
    # For non TLS, an error Failure configuring LB attributes: ValidationError: Access Denied for bucket
    #--------------------------------------------------------------------------------
    enabled = var.enable_access_logs
  }

  tags = var.tags
  enable_deletion_protection = false
}

#--------------------------------------------------------------------------------
# TODO: Consider 1 to 1 and 1 to N relationshipo
# Currently expecting Listener - Target Group has 1 to 1 relationship.
# Does not handndle 1 to many relationship in the nlb module.
#--------------------------------------------------------------------------------

#--------------------------------------------------------------------------------
# NLB Listener
# https://docs.aws.amazon.com/elasticloadbalancing/latest/network/create-network-load-balancer.html
#--------------------------------------------------------------------------------
resource "aws_lb_listener" "this" {
  count               = length(var.listeners)
  load_balancer_arn   = aws_lb.this.arn
  port                = "${var.listeners[count.index]["port"]}"
  protocol            = "${var.listeners[count.index]["protocol"]}"

  default_action {
    target_group_arn  = "${aws_lb_target_group.this[count.index].arn}"
    type              = "${var.listeners[count.index]["action"]}"
  }
}

#--------------------------------------------------------------------------------
# NLB Target Group
# https://docs.aws.amazon.com/elasticloadbalancing/latest/network/create-target-group.html
#
# TODO: Consider the case of multiple containers per task.
# NLB listener can have a target group which forwards to multiple targets (containers) in an EC2.
# AWS NLB can have a limitation of not being able to have one target.
#--------------------------------------------------------------------------------
resource "aws_lb_target_group" "this" {
  count = length(var.listeners)
  #--------------------------------------------------------------------------------
  # Workaround for Unable to modify alb target group using terraform
  # https://github.com/terraform-providers/terraform-provider-aws/issues/659
  # Without using name_prefix and life_cycle = create_before_destroy, Terraform
  # cannot recreate the ALB.
  # name_prefix length is max 6
  #--------------------------------------------------------------------------------
  name_prefix           = "${substr("${var.targets[count.index]["name"]}", 0, 6)}"

  #--------------------------------------------------------------------------------
  # For auto scalaing group, the target_type is "instance" as ASG is adding instances.
  # Otherwise, will encounter. the Error creating AutoScaling Group:
  # ValidationError: Provided Target Group has invalid target type.
  #--------------------------------------------------------------------------------
  target_type           = var.targets[count.index]["target_type"]
  #--------------------------------------------------------------------------------

  vpc_id                = var.vpc_id
  port                  = var.targets[count.index]["port"] == 0 ? local.DUMMY_PORT_FOR_DYNAMIC_MAPPING : var.targets[count.index]["port"]
  protocol              = var.targets[count.index]["protocol"]

  health_check {
    #--------------------------------------------------------------------------------
    # healthy_threshold and unhealthy_threshold must be the same for target_groups with TCP
    #--------------------------------------------------------------------------------
    healthy_threshold   = "3"
    unhealthy_threshold = "3"
    interval            = "30"

    #--------------------------------------------------------------------------------
    # Traffic Port
    # https://docs.aws.amazon.com/elasticloadbalancing/latest/APIReference/API_CreateTargetGroup.html
    # The default is traffic-port, which is the port on which each target receives traffic from the load balancer.
    #
    # Understanding Dynamic Port Mapping in Amazon ECS with Application Load Balancer
    # https://medium.com/@mohitshrestha02/understanding-dynamic-port-mapping-in-amazon-ecs-with-application-load-balancer-bf705ee0ca8e
    # Dynamic port mapping allows you to run multiple tasks over the same host using multiple random host ports(inspite of defined host port)
    #
    # NLB cannot use with dynamic port as in ECS tasks using dynamic ephemeral ports with failing health checks
    # https://forums.aws.amazon.com/message.jspa?messageID=805080
    # https://medium.com/@mohitshrestha02/understanding-dynamic-port-mapping-in-amazon-ecs-with-application-load-balancer-bf705ee0ca8e
    #--------------------------------------------------------------------------------
    port                = "traffic-port"
    #--------------------------------------------------------------------------------

    protocol            = "${var.targets[count.index]["protocol"]}"
    #--------------------------------------------------------------------------------
    # For NLB, you cannot set a custom value.
    # The default is 10 seconds for TCP & HTTPS, 6 seconds for HTTP.
    #--------------------------------------------------------------------------------
    #timeout             = "10"
    #--------------------------------------------------------------------------------
    enabled             = "${var.enable_health_check}"

  }

  #--------------------------------------------------------------------------------
  # TF bug. To make NLB TG work, need to specify stickiness.
  # https://github.com/terraform-providers/terraform-provider-aws/issues/9050
  # https://github.com/terraform-providers/terraform-provider-aws/issues/9093
  #--------------------------------------------------------------------------------
  stickiness {
    type    = "lb_cookie"
    enabled = var.enable_lb_stickiness
  }

  tags = "${merge(var.targets[count.index]["tags"], var.tags)}"

  lifecycle {
    create_before_destroy = true
  }
}

data "external" "get_nlb_ips" {
  #--------------------------------------------------------------------------------
  # To use user site packages:
  # export PYTHONPATH="~/.local/lib" for "~/.local/lib/python3.6/site-packages/boto3"
  # For Anaconda/Python venv, install boto3, botocore respectively.
  #
  # Otherwise boto3 not found error with Terraform:
  # Error: failed to execute "python3": Traceback (most recent call last):
  # File "../../../modules/nlb/get_nlb_private_ips.py", line 1, in <module>
  # import boto3
  # ModuleNotFoundError: No module named 'boto3'
  #--------------------------------------------------------------------------------
  program = [
    "python3",
    "${path.module}/get_nlb_private_ips.py"
  ]
  query = {
    aws_region    = var.REGION
    aws_nlb_name  = "${aws_lb.this.name}"
    aws_vpc_id    = "${aws_lb.this.vpc_id}"
  }
}

locals {
  aws_nlb_network_interface_ips = "${jsondecode(data.external.get_nlb_ips.result.private_ips)}"
  aws_nlb_network_interface_cidr_blocks = [ for ip in local.aws_nlb_network_interface_ips : "${ip}/32" ]
}
