#--------------------------------------------------------------------------------
# S3 VCP endpoint prefix list (CIDR of the S3 endpoints creatd in VPC)
# To be used to setup NACL to/from the S3 endpoint.
#--------------------------------------------------------------------------------
data "aws_prefix_list" "s3" {
  prefix_list_id = module.vpc.vpc_endpoint_s3_pl_id
}

output "s3_cidr_count" {
  value = length(data.aws_prefix_list.s3.cidr_blocks)
}

output "s3_cidr" {
  value = data.aws_prefix_list.s3.cidr_blocks
}

