output "aws_lb_dns_name" {
  value = "${aws_lb.this.dns_name}"
}
output "aws_lb_id" {
  value = "${aws_lb.this.id}"
}
output "aws_lb_name" {
  value = "${aws_lb.this.name}"
}
output "aws_lb_arn" {
  value = aws_lb.this.arn
}
output "aws_lb_subnets" {
  value = "${aws_lb.this.subnets}"
}
output "aws_lb_enable_cross_zone_load_balancing" {
  value = "${aws_lb.this.enable_cross_zone_load_balancing}"
}
output "aws_lb_security_groups" {
  value = "${aws_lb.this.security_groups}"
}
output "aws_lb_internal" {
  value = "${aws_lb.this.internal}"
}
output "aws_lb_vpc_id" {
  value = "${aws_lb.this.vpc_id}"
}
output "aws_lb_load_balancer_type" {
  value = "${aws_lb.this.load_balancer_type}"
}

#--------------------------------------------------------------------------------
# NLB IP
#--------------------------------------------------------------------------------
output "aws_nlb_network_interface_ips" {
  value = "${local.aws_nlb_network_interface_ips}"
}
output "aws_nlb_network_interface_cidr_blocks" {
  value = "${local.aws_nlb_network_interface_cidr_blocks}"
}

#--------------------------------------------------------------------------------
# Listener
#--------------------------------------------------------------------------------
output "aws_lb_listener_arns" {
  value = "${aws_lb_listener.this.*.arn}"
}

#--------------------------------------------------------------------------------
# Target group
#--------------------------------------------------------------------------------
output "aws_lb_target_group_arns" {
  value = "${aws_lb_target_group.this.*.arn}"
}


