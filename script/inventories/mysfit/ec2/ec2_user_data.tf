locals {
  user_data = templatefile(
    "${path.module}/ec2/userdata_TBD_service.template",
    {
      #--------------------------------------------------------------------------------
      # ECS cluster name MUST match with the name of the existing one to join.
      # echo ECS_CLUSTER=${ecs_cluster_name} >> /etc/ecs/ecs.config
      #--------------------------------------------------------------------------------

      #--------------------------------------------------------------------------------
      # TODO: Need to imporove:
      # Due to the cyclyc dependency ECS Cluster -> ASG -> LC -> EC2/ECS Agent -> ECS Cluster,
      # cannot dynamically load the ECS cluster name. Hence, hard-code the static name.
      #
      # An alternative is to create ECS cluster first, and then add the ASG to the
      # ECS clsuter with put-cluster-capacity-providers.
      # https://docs.aws.amazon.com/cli/latest/reference/ecs/put-cluster-capacity-providers.html
      #--------------------------------------------------------------------------------
      #ecs_cluster_name       = "${local.ecs_cluster_name}"
      ecs_cluster_name       = "${var.PROJECT}_${var.ENV}_${local.ecs_cluster_name}"
      #--------------------------------------------------------------------------------

      ec2_user               = "${var.ec2_user_for_ecs_cluster}"
      docker_repository_host = local.docker_registry_host
      docker_repository_port = local.docker_registry_port
    }
  )
}
