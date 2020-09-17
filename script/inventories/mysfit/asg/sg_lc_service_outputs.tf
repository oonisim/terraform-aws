#--------------------------------------------------------------------------------
# ECS EC2 SG for ECS service
#--------------------------------------------------------------------------------
output "sg_ecs_service_ABC_id" {
  value = aws_security_group.lc_ecs_cluster_service_ABC.id
}
output "sg_ecs_service_ABC_ingress" {
  value = aws_security_group.lc_ecs_cluster_service_ABC.ingress
}
output "sg_ecs_service_ABC_egress" {
  value = aws_security_group.lc_ecs_cluster_service_ABC.egress
}
output "sg_lc_ecs_cluster_debug_ids" {
  value = aws_security_group.lc_ecs_cluster_debug[*].id
}

#--------------------------------------------------------------------------------
# ECS EC2 SG for SSH
#--------------------------------------------------------------------------------
output "sg_lc_ecs_cluster_ssh_id" {
  value = "${aws_security_group.lc_ecs_cluster_ssh.id}"
}

#--------------------------------------------------------------------------------
# ECS EC2 SG for ECS service
#--------------------------------------------------------------------------------
output "sg_ec2_ecs_service_ids" {
  value = local.sg_ec2_ecs_service_ids
}

#--------------------------------------------------------------------------------
# NLB IPs
#--------------------------------------------------------------------------------
output "aws_nlb_network_interface_cidr_blocks" {
  description = "Static IP address of the NLB"
  value = local.lb_microservice_XYZ_load_balancer_type == "network" ? data.terraform_remote_state.lb.outputs.aws_nlb_network_interface_cidr_blocks : ["NA for non-NLB"]
}

