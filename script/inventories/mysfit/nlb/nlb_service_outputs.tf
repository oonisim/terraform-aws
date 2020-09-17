#--------------------------------------------------------------------------------
# LB
#--------------------------------------------------------------------------------
output "aws_lb_id" {
  value = "${module.nlb_myecs_service.aws_lb_id}"
}
output "aws_lb_name" {
  value = "${module.nlb_myecs_service.aws_lb_name}"
}
output "aws_lb_dns_name" {
  value = "${module.nlb_myecs_service.aws_lb_dns_name}"
}
output "aws_lb_arn" {
  value = "${module.nlb_myecs_service.aws_lb_arn}"
}
output "aws_lb_subnets" {
  value = "${module.nlb_myecs_service.aws_lb_subnets}"
}
output "aws_lb_enable_cross_zone_load_balancing" {
  value = "${module.nlb_myecs_service.aws_lb_enable_cross_zone_load_balancing}"
}
output "aws_lb_security_groups" {
  value = "${module.nlb_myecs_service.aws_lb_security_groups}"
}
output "aws_lb_internal" {
  value = "${module.nlb_myecs_service.aws_lb_internal}"
}
output "aws_lb_vpc_id" {
  value = "${module.nlb_myecs_service.aws_lb_vpc_id}"
}
output "aws_lb_load_balancer_type" {
  value = "${module.nlb_myecs_service.aws_lb_load_balancer_type}"
}

#--------------------------------------------------------------------------------
# NLB IP
#--------------------------------------------------------------------------------
output "aws_nlb_network_interface_ips" {
  value = "${module.nlb_myecs_service.aws_nlb_network_interface_ips}"
}
output "aws_nlb_network_interface_cidr_blocks" {
  value = "${module.nlb_myecs_service.aws_nlb_network_interface_cidr_blocks}"
}

#--------------------------------------------------------------------------------
# Listener
#--------------------------------------------------------------------------------
output "aws_lb_listener_arns" {
  value = "${module.nlb_myecs_service.aws_lb_listener_arns}" # list
}

#--------------------------------------------------------------------------------
# Target group
#--------------------------------------------------------------------------------
output "aws_lb_target_group_arns" {
  value = "${module.nlb_myecs_service.aws_lb_target_group_arns}" # List
}