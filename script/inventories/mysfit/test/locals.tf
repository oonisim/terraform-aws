locals {
  vpc_ecs_cluster_id                    = "${data.terraform_remote_state.vpc.outputs.vpc_id}"
  vpc_ecs_cluster_cidr_block            = data.terraform_remote_state.vpc.outputs.vpc_cidr_block
  ecs_cluster_public_subnet_cidr_blocks = "${flatten([data.terraform_remote_state.vpc.outputs.public_subnets_cidr_blocks])}"
  ecs_cluster_public_subnet_ids         = "${flatten([data.terraform_remote_state.vpc.outputs.public_subnets])}"
  ecs_cluster_name                      = data.terraform_remote_state.ecs.outputs.aws_ecs_cluster_name
  elb_dns_name                          = data.terraform_remote_state.lb.outputs.aws_lb_dns_name
}
