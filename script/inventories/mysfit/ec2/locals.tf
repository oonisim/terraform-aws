locals {
  #----------------------------------------------------------------------
  # Normalize the path delimitar.
  # Terraform uses \ on Windows causing an error mixing them up with /.
  # "\terraform\modules\api/lambda/python.zip: The system cannot find the file specified"
  # https://github.com/hashicorp/terraform/issues/14986
  #----------------------------------------------------------------------

  #----------------------------------------------------------------------
  # No more required to handle backslash
  # https://github.com/hashicorp/terraform/issues/20064
  # We are also changing the path variables and path functions to always use forward slashes, even on Windows, for similar reasons.
  #module_path = replace(path.module, "\\", "/")
  #----------------------------------------------------------------------
  module_path = "${path.cwd}/${path.module}"
}

#--------------------------------------------------------------------------------
# Indirection (remote state)
#--------------------------------------------------------------------------------
# VPC
locals {
  vpc_ecs_cluster_id                    = "${data.terraform_remote_state.vpc.outputs.vpc_id}"
  vpc_ecs_cluster_cidr_block            = data.terraform_remote_state.vpc.outputs.vpc_cidr_block
  subnet_ecs_cluster_asg_ids            = "${flatten([data.terraform_remote_state.vpc.outputs.private_subnets])}"
}

#--------------------------------------------------------------------------------
# ALB can have SG hence, ASG can restrict access only from the ALB SG.
# NLB cannot have SG, hence ASG restricts access only from the NLB IPs.
#--------------------------------------------------------------------------------
locals {
  lb_microservice_XYZ_id                 = "${data.terraform_remote_state.lb.outputs.aws_lb_id}"
  #--------------------------------------------------------------------------------
  # Currently only handles single load balancer.
  # For multi load balancers, need to modify SG to be able to handle all LB types.
  #--------------------------------------------------------------------------------
  lb_microservice_XYZ_target_group_arns  = "${data.terraform_remote_state.lb.outputs.aws_lb_target_group_arns}"
  lb_microservice_XYZ_load_balancer_type = "${data.terraform_remote_state.lb.outputs.aws_lb_load_balancer_type}"

  #--------------------------------------------------------------------------------
  # Conditional cannot be used in locals block
  # https://github.com/hashicorp/terraform/issues/21855
  #--------------------------------------------------------------------------------
  # ALB SG ID
  #sg_lb_microservice_XYZ_id  = "${local.lb_microservice_XYZ_load_balancer_type == "application" ? data.terraform_remote_state.lb.outputs.sg_alb_for_ecs_service_ABC_id : null}"
  # NLB IPs
  #sg_lb_microservice_XYZ_ips = local.lb_microservice_XYZ_load_balancer_type == "network" ? data.terraform_remote_state.lb.outputs.aws_nlb_network_interface_ips : null
  #sg_lb_microservice_XYZ_cidr_blocks = "${local.lb_microservice_XYZ_load_balancer_type == "network" ? data.terraform_remote_state.lb.outputs.aws_nlb_network_interface_cidr_blocks : null}"
  #--------------------------------------------------------------------------------
}

locals {
  sg_lc_ecs_cluster_debug_ids = aws_security_group.lc_ecs_cluster_debug[*].id
  sg_lc_ecs_cluster_service_ABC    = aws_security_group.lc_ecs_cluster_service_ABC.id
  sg_lc_ecs_cluster_ssh_id    = aws_security_group.lc_ecs_cluster_ssh.id
}

locals {
  #----------------------------------------------------------------------
  # Amazon ECR Registries
  # https://docs.aws.amazon.com/AmazonECR/latest/userguide/Registries.html
  #----------------------------------------------------------------------
  docker_registry_host = data.terraform_remote_state.common.outputs.docker_registry_host
  docker_registry_port = data.terraform_remote_state.common.outputs.docker_registry_port
}
output "docker_registry_host" {
  value = local.docker_registry_host
}
output "docker_registry_port" {
  value = local.docker_registry_port
}