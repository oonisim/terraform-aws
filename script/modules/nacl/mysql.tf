#--------------------------------------------------------------------------------
# NACL ingress rule for MySQL
#--------------------------------------------------------------------------------
resource "aws_network_acl_rule" "mysql_in" {
  count          = "${var.enable_mysql == true ? length(var.forign_cidr_blocks) : 0}"
  network_acl_id = "${aws_network_acl.this.id}"
  rule_number    = "${ 401 + count.index }"
  egress         = false
  protocol       = "tcp"
  rule_action    = "${var.action}"
  cidr_block     = "${element(var.forign_cidr_blocks, count.index)}"
  from_port      = 3306
  to_port        = 3306
}
#--------------------------------------------------------------------------------
# NACL egress rule from MySQL back to ephemeral ports in the public subnet.
#--------------------------------------------------------------------------------
resource "aws_network_acl_rule" "mysql_out" {
  count          = "${var.enable_mysql == true ? length(var.forign_cidr_blocks) : 0}"
  network_acl_id = "${aws_network_acl.this.id}"
  rule_number    = "${ 410 + count.index }"
  egress         = true
  protocol       = "tcp"
  rule_action    = "${var.action}"
  cidr_block     = "${element(var.forign_cidr_blocks, count.index)}"
  from_port      = 1024
  to_port        = 65535
}
