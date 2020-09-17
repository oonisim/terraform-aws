locals {
  sg_asg_myecs_service = [
    aws_security_group.lc_ecs_cluster_ssh.id,
    aws_security_group.lc_ecs_cluster_service_ABC.id
  ]
}