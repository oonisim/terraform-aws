locals {
  #--------------------------------------------------------------------------------
  # For ELB target port, when 0 is passed when dynamic port mapping is used, then specify dummpy port.
  # Use Echo service default port
  #--------------------------------------------------------------------------------
  DUMMY_PORT_FOR_DYNAMIC_MAPPING = 7  # Echo service
}

resource "aws_lb" "this" {
  load_balancer_type = "application"
  name               = replace("${var.PROJECT}-${var.ENV}-${var.name}", "/[_.]/", "-")
  internal           = false

  #--------------------------------------------------------------------------------
  # Need to be in a subnet with internet access
  #--------------------------------------------------------------------------------
  subnets            = flatten(["${var.subnet_ids}"])
  enable_cross_zone_load_balancing = true

  #--------------------------------------------------------------------------------
  # The outbound is to the LB target.
  #--------------------------------------------------------------------------------
  # Target shoould be the SG of the target instances, however,
  # because of cyclic reference of ALB SG to EC2/LC SG, and EC2/LC SG from ALB SG,
  # it is not possible to use SG...
  #--------------------------------------------------------------------------------
  security_groups    = flatten(["${var.security_group_ids}"])

  access_logs {
    bucket  = var.bucket_log_name
    prefix  = "${var.PROJECT}-${var.ENV}-${var.name}"
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
  target_type           = "${var.targets[count.index]["target_type"]}"
  #--------------------------------------------------------------------------------

  vpc_id                = "${var.vpc_id}"
  port                  = var.targets[count.index]["port"] == 0 ? local.DUMMY_PORT_FOR_DYNAMIC_MAPPING : var.targets[count.index]["port"]
  protocol              = "${var.targets[count.index]["protocol"]}"

  #--------------------------------------------------------------------------------
  # How do I set up dynamic port mapping for Amazon ECS?
  # https://aws.amazon.com/premiumsupport/knowledge-center/dynamic-port-mapping-ecs/
  #--------------------------------------------------------------------------------
  health_check {
    healthy_threshold   = "5"
    unhealthy_threshold = "3"
    interval            = "30"
    matcher             = "200"
    path                = "/"
    #--------------------------------------------------------------------------------
    # https://docs.aws.amazon.com/elasticloadbalancing/latest/APIReference/API_CreateTargetGroup.html
    # The default is traffic-port, which is the port on which each target receives traffic from the load balancer.
    #--------------------------------------------------------------------------------
    port                = "traffic-port"
    #--------------------------------------------------------------------------------
    protocol            = "${var.targets[count.index]["protocol"]}"
    timeout             = "5"
  }

  tags = {
    Name = "${var.PROJECT}_${var.ENV}_${var.name}_${count.index}"
  }

  stickiness {
    enabled = true
    type = "lb_cookie"
  }

  lifecycle {
    create_before_destroy = true
  }
}
