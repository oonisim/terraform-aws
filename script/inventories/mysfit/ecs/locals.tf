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

locals {
  asg_ecs_cluster_arn = local.enable_ecs_cluster_auto_scaling ? data.terraform_remote_state.asg.outputs.asg_ecs_cluster_arn : null
}

locals {
  lb_id                  = data.terraform_remote_state.lb.outputs.aws_lb_id
  lb_target_group_arns   = data.terraform_remote_state.lb.outputs.aws_lb_target_group_arns
  lb_load_balancer_type  = data.terraform_remote_state.lb.outputs.aws_lb_load_balancer_type
}
output "lb_target_group_arns" {
  value = local.lb_target_group_arns
}

