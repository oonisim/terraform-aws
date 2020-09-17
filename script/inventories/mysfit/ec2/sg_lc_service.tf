#================================================================================
# SG for ECS EC2 instances. Need to handle depending on ALB or NLB.
#
# [SSH]
# Ingress accepts SSH traffic from VPC CIDR (not limit to specific subnet CIDR blocks)
#
# [ECS Agent]
# Egress allows all traffic to all the AWS service endpoints. Handle private VPCEs and public respectively.
# ECS agent does not require any incoming SG rules, it only initiates outboundconnections
# to ECS service, ECR, and other services e.g. Security Manager, S3, etc.
#
# TODO: Consider if egress limiting to VPC CIDR block is worthwhile.
# It would not be, because ECS EC2 is in private subnets. For public, it only goes through NAT.
# For private, the traffic stays inside the private subnets.
# TODO: Consider ingress limiting to traffic from the same AZ to prevent cross AZ traffic.
#       It should not happen if stickiness has been properly configured.
#
# [ALB]
# Ingress accepts traffic from ALB SG.
#
# [NLB]
# Ingress accepts traffic from NLB private IPs ONLY IF NLB target type is IP.
# For instance IP target, the source IP for Instance ID targets.
#
# * Source IP Preservation
# If you specify targets using an instance ID, the source IP addresses of the clients are preserved and provided to your applications.
# If you specify targets by IP address, the source IP addresses are the private IP addresses of the load balancer nodes.
# https://docs.aws.amazon.com/elasticloadbalancing/latest/network/load-balancer-target-groups.html
#
#
# [Bastion EC2 instance traffic]
# How to allow testing the connectivities to the microservice host ports?
#================================================================================


#--------------------------------------------------------------------------------
# [Debug]
# For ECS/EC2 connectivity deugging, allow all incoming from the VPC CIDR
#--------------------------------------------------------------------------------
resource "aws_security_group" "lc_ecs_cluster_debug" {
  count = local.ENABLE_ECS_EC2_CONNECTION_DEBUG ? 1 : 0
  name = "${var.PROJECT}_${var.ENV}_sg_lc_ecs_cluster_debug"
  vpc_id = local.vpc_ecs_cluster_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = flatten([
      local.vpc_ecs_cluster_cidr_block
    ])
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  lifecycle {
    create_before_destroy = true
  }
}

#--------------------------------------------------------------------------------
# [SSH]
# Allow SSH incoming from within VPC CIDR.
#--------------------------------------------------------------------------------
resource "aws_security_group" "lc_ecs_cluster_ssh" {
  name = "${var.PROJECT}_${var.ENV}_sg_lc_ecs_cluster_ssh"
  vpc_id = local.vpc_ecs_cluster_id

  ingress {
    from_port   = var.lc_ecs_cluster_ssh_port
    to_port     = var.lc_ecs_cluster_ssh_port
    protocol    = var.lc_ecs_cluster_ssh_protocol
    cidr_blocks = flatten([
      local.vpc_ecs_cluster_cidr_block
    ])
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  lifecycle {
    create_before_destroy = true
  }
}


#--------------------------------------------------------------------------------
# [ECS]
# Allow incoming access to ECS task microservice ports from ELB.
#
# Limitatino:
# Currently, for Instance target type of the ELB target group, there is not a way to control
# the traffic comes only from NLB, as it preserves source IP for Instance target type, and
# NLB has no SG.
# https://stackoverflow.com/questions/60431236/how-to-limit-the-access-to-ec2-from-nlb-only
#
# NLB - Register Targets with Your Target Group
# NLB has no associated SG. The SG at your targets must use IP addresses to allow traffic from NLB.
# Cannot allow traffic from external clients to targets (that goes through NLB) using the SG.
# Use the client CIDR blocks in the target SG instead. (Cannot control traffic from NLB with SG).
# https://docs.aws.amazon.com/elasticloadbalancing/latest/network/target-group-register-targets.html#target-security-groups
# TODO: Dynamic ingress blocks to handle all the microservices in the same ECS service
#--------------------------------------------------------------------------------
resource "aws_security_group" "lc_ecs_cluster_service_ABC" {
  name = "${var.PROJECT}_${var.ENV}_sg_lc_ecs_cluster_service_${local.ecs_service_ABC_name}"

  vpc_id = local.vpc_ecs_cluster_id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  #--------------------------------------------------------------------------------
  # Service traffic from ALB
  #--------------------------------------------------------------------------------
  dynamic "ingress" {
    # TODO: Incorporate multiple microservices, not just one
    for_each = "${ local.lb_microservice_XYZ_load_balancer_type == "application" ? list("dummy") : [] }"
    content{
      #--------------------------------------------------------------------------------
      # The docker ephemeral port ranges for dynamic port mappings
      # https://aws.amazon.com/premiumsupport/knowledge-center/dynamic-port-mapping-ecs/
      #--------------------------------------------------------------------------------
      #from_port   = local.ec2_host_port_for_microservice_XYZ
      #to_port     = local.ec2_host_port_for_microservice_XYZ
      from_port   = local.ec2_host_port_for_microservice_XYZ == 0 ? local.DOCKER_EPHEMERAL_FROM_PORT : local.ec2_host_port_for_microservice_XYZ
      to_port     = local.ec2_host_port_for_microservice_XYZ == 0 ? local.DOCKER_EPHEMERAL_TO_PORT   : local.ec2_host_port_for_microservice_XYZ
      #--------------------------------------------------------------------------------

      #--------------------------------------------------------------------------------
      # Protocol for ALB (HTTP/HTTPS) is TCP
      #--------------------------------------------------------------------------------
      #protocol    = local.protocol_for_microservice_XYZ
      protocol    = "tcp"
      #--------------------------------------------------------------------------------

      #--------------------------------------------------------------------------------
      # Allow connections only from SG of the load balancer
      # Directly using data.terraform_remote_state.lb.outputs.sg_alb_for_ecs_service_ABC_id
      # instead of indirection via local, because locals block cannot use conditional
      # as in https://github.com/hashicorp/terraform/issues/21855.
      #
      # TODO: Replace with local as the issue has been fixed in https://github.com/hashicorp/terraform/pull/21957
      #--------------------------------------------------------------------------------
      security_groups = list(data.terraform_remote_state.lb.outputs.sg_alb_for_ecs_service_ABC_id)
    }
  }
  #--------------------------------------------------------------------------------
  # Healthcheck from ALB target group
  # The ELB target group healthcheck is set to test against "traffic-port".
  # Hence no configuration for healthcheck port.
  #--------------------------------------------------------------------------------
  /*
  dynamic "ingress" {
    for_each = "${ local.lb_microservice_XYZ_load_balancer_type == "application" ? list("dummy") : [] }"
    content{
      from_port   = "${var.ec2_microservice_XYZ_healthcheck_host_port}"
      to_port     = "${var.ec2_microservice_XYZ_healthcheck_host_port}"
      protocol    = "${var.ec2_microservice_XYZ_healthcheck_protocol}"
      security_groups = list(data.terraform_remote_state.lb.outputs.sg_alb_for_ecs_service_ABC_id)
    }
  }
  */

  # TODO: Verify NLB IP address filtering at SG works or not.
  #--------------------------------------------------------------------------------
  # Service traffic from NLB
  #--------------------------------------------------------------------------------
  # Allow connections only from the load balancer IPs
  #
  # !!! MUST specify targets by IP, NOT by instance ID !!!
  # For ELB instance ID target, Source IP Preservation of NLB passes the source IP
  # of the actual clieent, NOT NLB.
  #
  # [Source IP Preservation - AWS NLB document]
  # If you specify targets by IP address, the source IP addresses are the private IP addresses of the load balancer nodes.
  # If you specify targets using an instance ID, the source IP addresses of the clients are preserved and provided to your applications.
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/network/load-balancer-target-groups.html#target-type
  # https://stackoverflow.com/questions/60431236/how-to-limit-the-access-to-ec2-from-nlb-only
  #--------------------------------------------------------------------------------
  dynamic "ingress" {
    for_each = "${ local.lb_microservice_XYZ_load_balancer_type == "network" ? list("dummy") : [] }"
    content{
      #--------------------------------------------------------------------------------
      # The docker ephemeral port ranges for dynamic port mappings
      # https://aws.amazon.com/premiumsupport/knowledge-center/dynamic-port-mapping-ecs/
      #--------------------------------------------------------------------------------
      #from_port   = local.ec2_host_port_for_microservice_XYZ
      #to_port     = local.ec2_host_port_for_microservice_XYZ
      from_port   = local.ec2_host_port_for_microservice_XYZ == 0 ? local.DOCKER_EPHEMERAL_FROM_PORT : local.ec2_host_port_for_microservice_XYZ
      to_port     = local.ec2_host_port_for_microservice_XYZ == 0 ? local.DOCKER_EPHEMERAL_TO_PORT   : local.ec2_host_port_for_microservice_XYZ
      #--------------------------------------------------------------------------------

      #--------------------------------------------------------------------------------
      # Protocol for NLB.
      # TODO: Handle when protocol_for_microservice_XYZ is TCP_UDP. Test UDP
      # For TCP_UDP, would require two ingress rules, one for TCP and one for UDP for the same port.
      #
      # SG protocol are tcp, udp, icmp, icmpv6
      # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-ec2-security-group-rule-1.html
      #--------------------------------------------------------------------------------
      protocol    = local.protocol_for_microservice_XYZ

      #--------------------------------------------------------------------------------
      # NLB CIDR
      # Directly refering to remote_state to avoid testing if ELB is NLB or ALB, as this is inside the
      # dyanmic block which is testing it too.
      #cidr_blocks = var.ec2_sg_microservice_XYZ_external_client_cidr_blocks
      #--------------------------------------------------------------------------------

      #--------------------------------------------------------------------------------
      # There is an issue of "bridge" network mode is incompatible with ELB "ip" target type.
      # (At the global level, the target type is configured based on the network mode, but double check it)
      #
      # Change the CIDR block from where to accept the traffice.
      # - For "ip"" target type where NLB IPs are the source IP, use NLB IPs as CIDR.
      # - For "instance" target type when NLB preserves the source IP, need to open up to the world unfortunately.
      #   Need to protect the ECS/EC2 in some other ways.
      #
      # [target type ip is incompatible with the bridge network mode specified in the task definition]
      # https://github.com/hashicorp/terraform/issues/24266
      # https://github.com/terraform-providers/terraform-provider-aws/issues/12252
      #--------------------------------------------------------------------------------
      cidr_blocks = local.elb_target_type_for_ecs_task_ABC == "ip" ? data.terraform_remote_state.lb.outputs.aws_nlb_network_interface_cidr_blocks : local.ingress_cidr_blocks_at_elb_for_service_ABC
    }
  }

  #--------------------------------------------------------------------------------
  # Healthcheck from NLB target group
  # The ELB target group healthcheck is set to test against "traffic-port".
  # Hence no configuration for healthcheck port.
  #--------------------------------------------------------------------------------
  /*
  dynamic "ingress" {
    for_each = "${local.lb_microservice_XYZ_load_balancer_type == "network" ? list("dummy") : [] }"
    content{
      from_port   = "${var.ec2_microservice_XYZ_healthcheck_host_port}"
      to_port     = "${var.ec2_microservice_XYZ_healthcheck_host_port}"
      protocol    = "${var.ec2_microservice_XYZ_healthcheck_protocol}"
      cidr_blocks = data.terraform_remote_state.lb.outputs.aws_nlb_network_interface_cidr_blocks
    }
  }
  */
  lifecycle {
    create_before_destroy = true
  }
}

#--------------------------------------------------------------------------------
# SG IDs to attach to the ASG EC2 instances
#--------------------------------------------------------------------------------
locals {
  sg_ec2_ecs_service_ids = flatten([
    aws_security_group.lc_ecs_cluster_debug[*].id,
    aws_security_group.lc_ecs_cluster_ssh.id,
    aws_security_group.lc_ecs_cluster_service_ABC.id
  ])
}