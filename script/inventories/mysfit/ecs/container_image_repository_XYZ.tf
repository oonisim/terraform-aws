#--------------------------------------------------------------------------------
# Micro-service image repository for the service
# Each service has its own repository, not a directory in repository, although
# the repository_url has the path structure "path/to/service" (confusion point).
#--------------------------------------------------------------------------------
resource "aws_ecr_repository" "XYZ" {
  #name = lower("${var.PROJECT}_${var.ENV}_${var.ecs_cluster_name}/${var.microservice_XYZ_name}")
  name = lower("${var.PROJECT}_${var.ENV}_${local.ecs_cluster_name}/${local.microservice_XYZ_name}")
}

#--------------------------------------------------------------------------------
# Indirection
#--------------------------------------------------------------------------------
locals {
  container_image_registry_XYZ_arn  = aws_ecr_repository.XYZ.arn
  container_image_registry_XYZ_name = aws_ecr_repository.XYZ.name
  container_image_registry_XYZ_url  = aws_ecr_repository.XYZ.repository_url
}