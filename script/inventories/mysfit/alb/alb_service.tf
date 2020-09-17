module "alb_myecs_service" {
  source              = "../../../modules/alb"
  name                = local.microservice_XYZ_name

  PROJECT             = var.PROJECT
  ENV                 = var.ENV
  REGION              = var.REGION

  is_internal         = false

  vpc_id              = local.vpc_ecs_cluster_id
  subnet_ids          = local.vpc_microservice_XYZ_alb_subnet_ids
  security_group_ids  = [
    local.sg_alb_for_ecs_service_ABC_id
  ]

  listeners           = local.alb_listeners_for_ecs_service_ABC
  targets             = local.alb_target_groups_for_ecs_service_ABC

  enable_access_logs  = var.alb_enable_access_logs
  bucket_log_name     = local.bucket_alb_log_id

  tags                = {
    "Project"     = var.PROJECT
    "Environment" = var.ENV
  }
}
