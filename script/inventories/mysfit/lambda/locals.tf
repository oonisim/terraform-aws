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
  vpc_ecs_cluster_id                    = "${data.terraform_remote_state.vpc.outputs.vpc_id}"
  vpc_ecs_cluster_cidr_block            = data.terraform_remote_state.vpc.outputs.vpc_cidr_block
  ecs_cluster_public_subnet_cidr_blocks = "${flatten([data.terraform_remote_state.vpc.outputs.public_subnets_cidr_blocks])}"
  ecs_cluster_public_subnet_ids         = "${flatten([data.terraform_remote_state.vpc.outputs.public_subnets])}"
  ecs_cluster_private_subnet_cidr_blocks = "${flatten([data.terraform_remote_state.vpc.outputs.private_subnets_cidr_blocks])}"
  ecs_cluster_private_subnet_ids         = "${flatten([data.terraform_remote_state.vpc.outputs.private_subnets])}"

  # Bucket to upload lambda package
  bucket_name = data.terraform_remote_state.s3.outputs.bucket_data

  # API to invoke
  apigw_mysfit_invoke_url    = data.terraform_remote_state.apigw.outputs.api_gateway_deployment_invoke_url
}
