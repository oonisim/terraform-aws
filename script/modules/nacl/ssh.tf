#--------------------------------------------------------------------------------
# NACL ingress rule for SSH only from public subnet.
#--------------------------------------------------------------------------------
resource "aws_network_acl_rule" "ssh_in" {
  count          = "${var.enable_ssh == true ? length(var.forign_cidr_blocks) : 0}"
  network_acl_id = "${aws_network_acl.this.id}"
  rule_number    = "${ 101 + count.index }"
  egress         = false
  protocol       = "tcp"
  rule_action    = "${var.action}"
  # foreign subnets from where ingress is ${var.action}ed
  cidr_block     = "${element(var.forign_cidr_blocks, count.index)}"
  from_port      = 22
  to_port        = 22
}
#--------------------------------------------------------------------------------
# NACL egress rule from ssh back only to public subnet.
#--------------------------------------------------------------------------------
resource "aws_network_acl_rule" "ssh_out" {
  count          = "${var.enable_ssh == true ? length(var.forign_cidr_blocks) : 0}"
  network_acl_id = "${aws_network_acl.this.id}"
  rule_number    = "${ 111 + count.index }"
  egress         = false
  protocol       = "tcp"
  rule_action    = "${var.action}"
  cidr_block     = "${element(var.forign_cidr_blocks, count.index)}"
  from_port      = 1024
  to_port        = 65535
}