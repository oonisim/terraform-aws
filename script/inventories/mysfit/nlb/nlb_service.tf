module "nlb_myecs_service" {
  source = "../../../modules/nlb"
  name   = "${local.microservice_XYZ_name}"

  PROJECT = var.PROJECT
  ENV     = var.ENV
  REGION  = var.REGION

  is_internal = false

  vpc_id     = local.vpc_ecs_cluster_id
  subnet_ids = "${local.subnet_ecs_cluster_nlb_ids}"

  listeners            = "${local.nlb_listeners_for_ecs_service_ABC}"
  targets              = "${local.nlb_target_groups_for_ecs_service_ABC}"
  enable_health_check  = "${var.enable_health_check}"
  enable_lb_stickiness = var.enable_lb_stickiness

  enable_access_logs = "${var.nlb_enable_access_logs}"
  bucket_log_name    = "${local.bucket_nlb_log_id}"

  tags = {
    "Project"     = var.PROJECT
    "Environment" = "${var.ENV}"
  }
}
