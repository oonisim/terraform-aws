#--------------------------------------------------------------------------------
# Create the Amazon ECS Resources
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/tutorial-cluster-auto-scaling-cli.html#cli-tutorial-cluster
#--------------------------------------------------------------------------------
resource "aws_ecs_capacity_provider" "asg" {
  #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  # Due to AWS ECS bug, cannot delete Capacity Provider once created. Hence causing the error
  # when re-running terrafor apply as terraform destroy cannot delete it.
  # [Error]
  # error creating capacity provider: ClientException: The specified capacity provider already exists.
  # To change the configuration of an existing capacity provider, update the capacity provider.
  #
  # [ECS] Add the ability to delete an ASG capacity provider. #632
  # https://github.com/aws/containers-roadmap/issues/632
  #
  # There is no aws_ecs_capacity_provider datasource as of now.
  # -> Raised https://github.com/terraform-providers/terraform-provider-aws/issues/12301
  #
  # Once fell in the situation, disable the capacity provider, and add the created one
  # manually.
  # https://stackoverflow.com/questions/60056801/aws-ecs-capacity-provider-using-terraform/60575634#60575634
  #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  # TODO: Enable once the bug is fixed.
  #count = local.enable_ecs_cluster_auto_scaling ? 1 : 0
  count = local.enable_ecs_cluster_auto_scaling ? 0 : 0
  #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  name = "${var.PROJECT}-${var.ENV}-ecs-cluster-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = local.asg_ecs_cluster_arn

    #--------------------------------------------------------------------------------
    # When using managed termination protection, managed scaling must also be used otherwise managed termination protection will not work.
    # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/cluster-capacity-providers.html#capacity-providers-considerations
    # Otherwise Error:
    # error creating capacity provider: ClientException: The managed termination protection setting for the capacity provider is invalid.
    # To enable managed termination protection for a capacity provider, the Auto Scaling group must have instance protection from scale in enabled.
    #--------------------------------------------------------------------------------
    managed_termination_protection = "ENABLED"

    managed_scaling {
      #--------------------------------------------------------------------------------
      # Whether auto scaling is managed by ECS. Valid values are ENABLED and DISABLED.
      # When creating a capacity provider, you can optionally enable managed scaling.
      # When managed scaling is enabled, ECS manages the scale-in/out of the ASG.
      #--------------------------------------------------------------------------------
      status                    = "ENABLED"
      minimum_scaling_step_size = local.ecs_cluster_autoscaling_min_step_size
      maximum_scaling_step_size = local.ecs_cluster_autoscaling_max_step_size
      target_capacity           = local.ecs_cluster_autoscaling_target_capacity
    }
  }
}


# Expose I/F
locals {
  aws_ecs_capacity_provider_asg_names = local.enable_ecs_cluster_auto_scaling ? aws_ecs_capacity_provider.asg[*].name : []
  aws_ecs_capacity_provider_asg_arns  = local.enable_ecs_cluster_auto_scaling ? aws_ecs_capacity_provider.asg[*].arn : []
}

output "aws_ecs_capacity_provider_asg_names" {
  value = local.aws_ecs_capacity_provider_asg_names
}

output "aws_ecs_capacity_provider_asg_arns" {
  value = local.aws_ecs_capacity_provider_asg_arns
}