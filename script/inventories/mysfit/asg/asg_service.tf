#--------------------------------------------------------------------------------
# ASG terraform module
# https://registry.terraform.io/modules/terraform-aws-modules/autoscaling/aws/3.0.0
#--------------------------------------------------------------------------------
module "asg_ecs_cluster" {
  source = "../../../modules/asg"
  name = "${var.PROJECT}-${var.ENV}-asg-${local.ecs_cluster_name}"

  #--------------------------------------------------------------------------------
  # Service-Linked Role for Amazon ECS
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using-service-linked-roles.html
  #--------------------------------------------------------------------------------
  service_linked_role_arn = local.ecs_cluster_autoscaling_service_linked_role_arn

  #--------------------------------------------------------------------------------
  # Subnet
  #--------------------------------------------------------------------------------
  vpc_zone_identifier       = "${local.subnet_ecs_cluster_asg_ids}"

  #--------------------------------------------------------------------------------
  # LB TargetGroup
  #--------------------------------------------------------------------------------
  target_group_arns         = "${local.lb_microservice_XYZ_target_group_arns}"

  #--------------------------------------------------------------------------------
  # Use ELB to run service level (if app is responding)
  # EC2 is check if EC2 is avalive, NOT if the service is alive
  #--------------------------------------------------------------------------------
  health_check_type         = "${var.asg_ecs_cluster_health_check_type}"
  health_check_grace_period = var.asg_ec2_health_check_grace_period

  #--------------------------------------------------------------------------------
  # Capacity
  #--------------------------------------------------------------------------------
  min_size                  = "${local.ecs_cluster_autoscaling_min_size}"
  max_size                  = "${local.ecs_cluster_autoscaling_max_size}"
  desired_capacity          = "${local.ecs_cluster_autoscaling_target_capacity}"
  wait_for_elb_capacity     = 0
  protect_from_scale_in     = var.asg_protect_from_scale_in

  #--------------------------------------------------------------------------------
  # Launch configuration
  #--------------------------------------------------------------------------------
  recreate_asg_when_lc_changes = false
  create_lc = false # disables creation of launch configuration
  launch_configuration = local.lc_ecs_cluster_name
  /*
  security_groups = [
    flatten(local.sg_lc_ecs_cluster_debug_ids),
    "${local.sg_lc_ecs_cluster_service_ABC}",
    "${local.sg_lc_ecs_cluster_ssh_id}"
  ]
  */
  security_groups = local.sg_ec2_ecs_service_ids
  #ecurity_groups = "${flatten([local.sg_asg_myecs_service])}"
  /*
  lc_name =
  image_id        = "${data.aws_ami.asg_myecs_service.id}"
  #instance_type   = "${var.asg_ecs_cluster_instance_type}"
  security_groups = [
    "${local.sg_asg_ecs_cluster_id}",
    "${local.sg_asg_ecs_cluster_ssh_id}"
  ]
  */


  /*
  ebs_block_device = [
    {
      device_name           = "/dev/xvdz"
      volume_type           = "gp2"
      volume_size           = "50"
      delete_on_termination = true
    },
  ]

  root_block_device = [
    {
      volume_size = "50"
      volume_type = "gp2"
    },
  ]
  */

  tags = [
    {
      key                 = "Environment"
      value               = "${var.ENV}"
      propagate_at_launch = true
    },
    {
      key                 = "Project"
      value               = "${var.PROJECT}"
      propagate_at_launch = true
    },
  ]
}

#--------------------------------------------------------------------------------
# Inteface export (Program against local, not the resource implementation)
#--------------------------------------------------------------------------------
locals {
  asg_ecs_cluster_arn   = module.asg_ecs_cluster.autoscaling_group_arn
  asg_ecs_cluster_id   = module.asg_ecs_cluster.autoscaling_group_id
  asg_ecs_cluster_name = module.asg_ecs_cluster.autoscaling_group_name
}
