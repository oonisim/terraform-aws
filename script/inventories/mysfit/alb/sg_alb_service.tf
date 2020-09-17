#--------------------------------------------------------------------------------
# LB security group to communicate with registered targets on both the listener port and the health check port.
# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-update-security-groups.html
#
# TODO: Create SG at VPC level and pass them to ASG, ALB so that the access can be limited from SG
# TODO: Move ALB configurations e.g. port number to common module to have single location to manage.
#--------------------------------------------------------------------------------
resource "aws_security_group" "alb_ecs_service_ABC" {
  name = "${var.PROJECT}_${var.ENV}_sg_at_alb_for_ecs_service_ABC"
  vpc_id = local.vpc_ecs_cluster_id

  # TODO: Create ingress rules for multiple micro-services in the ECS service, as ECS service task can have multiple docker containers.
  ingress {
    #--------------------------------------------------------------------------------
    # ALB protocol (HTTP/HTTPS) is TCP.
    # [IpProtocol]
    # The IP protocol name (tcp, udp, icmp, icmpv6) or number (see Protocol Numbers).
    # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-ec2-security-group-rule-1.html
    #
    # [Protocol Numbers]
    # http://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml
    #--------------------------------------------------------------------------------
    #protocol    = local.protocol_for_microservice_XYZ
    protocol    = "tcp"
    #--------------------------------------------------------------------------------
    from_port   = local.client_port_for_microservice_XYZ
    to_port     = local.client_port_for_microservice_XYZ
    cidr_blocks = local.ingress_cidr_blocks_at_elb_for_service_ABC
  }

  #--------------------------------------------------------------------------------
  # No need to configure ALB SG to control the egress to the EC2 instance/port as
  # ECS automatically updates the ELB target group to point to the EC2 instance/port
  # dynamically when EC2 instance is added/removed.
  #--------------------------------------------------------------------------------
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  lifecycle {
    create_before_destroy = true
  }
}

#--------------------------------------------------------------------------------
# Expose I/F
#--------------------------------------------------------------------------------
locals {
  sg_alb_for_ecs_service_ABC_id = aws_security_group.alb_ecs_service_ABC.id
}

