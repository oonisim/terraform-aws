# Launch configuration
output "asg_ecs_cluster_launch_configuration_id" {
  description = "The ID of the launch configuration"
  value       = module.asg_ecs_cluster.launch_configuration_id
}

# Autoscaling group
output "asg_ecs_cluster_name" {
  description = "The autoscaling group name"
  value       = local.asg_ecs_cluster_arn
}
output "asg_ecs_cluster_id" {
  description = "The autoscaling group id"
  value       = local.asg_ecs_cluster_id
}
output "asg_ecs_cluster_arn" {
  description = "The autoscaling group arn"
  value       = local.asg_ecs_cluster_arn
}


output "lb_microservice_XYZ_load_balancer_type" {
  value = "${local.lb_microservice_XYZ_load_balancer_type}"
}
output "aws_lb_load_balancer_type" {
  value = "${data.terraform_remote_state.lb.outputs.aws_lb_load_balancer_type}"
}

