#--------------------------------------------------------------------------------
# NLB IP.
# NLB cannot have SG (NLB don't have Security Groups).
# To control access to the target instances, needs to get IP of NLB as in
# https://docs.aws.amazon.com/elasticloadbalancing/latest/network/target-group-register-targets.html#target-security-groups
#
# [Terraform PR]
# Currently alb_lb does not expose private_ips but there is a PR.
# https://github.com/terraform-providers/terraform-provider-aws/pull/2901
#--------------------------------------------------------------------------------
#--------------------------------------------------------------------------------
# [Issues raised]
# https://stackoverflow.com/questions/56713493/terraform-how-to-get-ip-address-of-aws-lb
#--------------------------------------------------------------------------------
/*
data "aws_network_interfaces" "this" {
  filter {
    name = "description"
    values = ["ELB net/${module.nlb_myecs_service.aws_lb_name}/*"]
  }
  filter {
    name = "vpc-id"
    values = [local.vpc_ecs_cluster_id]
  }
  filter {
    name = "status"
    values = ["in-use"]
  }
  filter {
    name = "attachment.status"
    values = ["attached"]
  }
}

locals {
  nlb_network_interface_ids = "${flatten(["${data.aws_network_interfaces.this.ids}"])}"
}

data "aws_network_interface" "ifs" {
  count = "${length(local.nlb_network_interface_ids)}"
  id = "${local.nlb_network_interface_ids[count.index]}"
}

locals {
  aws_nlb_network_interface_ips = "${flatten([data.aws_network_interface.ifs.*.private_ips])}"
  aws_nlb_network_interface_cidr_blocks = [ for ip in local.aws_nlb_network_interface_ips : "${ip}/32" ]
}

output "aws_nlb_network_interface_ids" {
  value = "${local.nlb_network_interface_ids}"
}
output "aws_nlb_network_interface_ips" {
  value = "${local.aws_nlb_network_interface_ips}"
}
output "aws_nlb_network_interface_cidr_blocks" {
  value = "${local.aws_nlb_network_interface_cidr_blocks}"
}
*/