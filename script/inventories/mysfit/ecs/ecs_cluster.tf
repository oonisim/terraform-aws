#--------------------------------------------------------------------------------
# Auto-scaling launch configuration usedata MUST tell the ECS agent in the EC2 to
# which ECS cluster to join by specifying the ECS cluster name.
#
# Verify that the ECS cluster name is passed to USERDATA of ECS/EC2 instances.
#
# TODO: Separate into ecs_cluster module with capacity provider.
#--------------------------------------------------------------------------------
resource "aws_ecs_cluster" "this" {
  name = "${var.PROJECT}_${var.ENV}_${local.ecs_cluster_name}"

  #--------------------------------------------------------------------------------
  # Due to AWS ECS bug, cannot delete Capacity Provider once created, causing the
  # error of resouce already exits.
  # [ECS] Add the ability to delete an ASG capacity provider. #632
  # https://github.com/aws/containers-roadmap/issues/632
  #
  # For now, create the capacity-provider somewhere and re-use it.
  # TODO: Update once the ECS bug is fixed
  #--------------------------------------------------------------------------------
  #capacity_providers = local.enable_ecs_cluster_auto_scaling == true ? aws_ecs_capacity_provider.asg[*].name : []
  capacity_providers = local.enable_ecs_cluster_auto_scaling == true ? [ "${var.PROJECT}-${var.ENV}-ecs-cluster-capacity-provider" ] : []
  #--------------------------------------------------------------------------------
}

data "external" "put_capacity_provider" {
  #--------------------------------------------------------------------------------
  # Add a capacity provider to the ECS clsuter.
  # To list the available capacity providers (exclude Fargate ones)
  # aws ecs describe-capacity-providers | jq -r '.capacityProviders[] | select(.status=="ACTIVE" and .name!="FARGATE" and .name!="FARGATE_SPOT") | .name'
  #
  # Need to wait for the cluster to be in stable state. Otherwise error:
  # An error occurred (UpdateInProgressException) when calling the PutClusterCapacityProviders operation:
  # The specified cluster is in a busy state.
  # Cluster attachments must be in UPDATE_COMPLETE or UPDATE_FAILED state before they can be updated.
  #--------------------------------------------------------------------------------
  count = local.enable_ecs_cluster_auto_scaling == true ? 1 : 0

  #--------------------------------------------------------------------------------
  # To use user site packages: (Otherwise boto3 not found error with Terraform)
  # export PYTHONPATH="~/.local/lib" for "~/.local/lib/python3.6/site-packages/boto3"
  #--------------------------------------------------------------------------------
  program = [
    "/bin/bash",
    "${path.module}/put_capacity_provider.sh"
  ]
  # DO NOT forget to pass the ECS clsuter name, otherwise it will look for "default"
  query   = {
    #--------------------------------------------------------------------------------
    # To create the dependency on the ECS cluster before runnig the external provider.
    #--------------------------------------------------------------------------------
    ecs_cluster_name       = aws_ecs_cluster.this.name
    #--------------------------------------------------------------------------------
    capacity_provider_name = "${var.PROJECT}-${var.ENV}-ecs-cluster-capacity-provider"
    aws_region             = var.REGION
  }
}

output "put_capacity_provider" {
  value = local.enable_ecs_cluster_auto_scaling == true ? [
    for i in range(length(data.external.put_capacity_provider[*].id)) : jsondecode(data.external.put_capacity_provider[i].result.json)
  ] : []
}
