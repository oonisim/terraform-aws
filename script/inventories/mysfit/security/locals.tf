#----------------------------------------------------------------------
# Common
#----------------------------------------------------------------------
locals {
  ecs_cluster_name = data.terraform_remote_state.common.outputs.ecs_cluster_name
}
