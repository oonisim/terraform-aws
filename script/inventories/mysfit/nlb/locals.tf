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
# Indirection
#--------------------------------------------------------------------------------
locals {
  vpc_ecs_cluster_id         = "${data.terraform_remote_state.vpc.outputs.vpc_id}"
  vpc_ecs_cluster_cidr_block = data.terraform_remote_state.vpc.outputs.vpc_cidr_block
  subnet_ecs_cluster_nlb_ids = "${flatten([data.terraform_remote_state.vpc.outputs.public_subnets])}"
  subnet_ecs_cluster_asg_ids = "${flatten([data.terraform_remote_state.vpc.outputs.private_subnets])}"
}

