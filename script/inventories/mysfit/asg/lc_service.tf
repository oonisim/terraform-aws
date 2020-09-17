locals {
  lc_ecs_cluster_name = "${module.lc_ecs_cluster.aws_launch_configuration_name}"
}

#--------------------------------------------------------------------------------
# EC2
#--------------------------------------------------------------------------------
# EC2 launch configuration for ECS cluster
module "lc_ecs_cluster" {
  source    = "../../../modules/lc"
  name      = "${var.lc_name}"

  PROJECT   = var.PROJECT
  ENV       = var.ENV
  REGION    = var.REGION

  spot_price            = var.spot_price

  ami_id                = "${local.ami_microservice_XYZ_id}"
  instance_type         = "${var.ec2_ecs_service_instance_type}"
  iam_instance_profile  = "${local.ec2_ecs_service_instance_profile_name}"

  user_data             = "${local.user_data}"

  keypair_public_key    = "${var.ec2_ecs_service_keypair_public_key}"

  root_volume_type      = "${var.ec2_ecs_service_volume_type}"
  root_volume_size      = "${var.ec2_ecs_service_volume_size}"

  security_group_ids    = [
    "${local.sg_lc_ecs_cluster_service_ABC}",
    "${local.sg_lc_ecs_cluster_ssh_id}"
  ]

}
