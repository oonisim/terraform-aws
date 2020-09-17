#--------------------------------------------------------------------------------
# NACL egress rule for HTTP (via NAT)
#--------------------------------------------------------------------------------
resource "aws_network_acl_rule" "http" {
  count          = "${var.enable_nat == true ? 1 : 0}"
  network_acl_id = "${aws_network_acl.this.id}"
  rule_number    = 201
  egress         = true
  protocol       = "tcp"
  rule_action    = "${var.action}"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

#--------------------------------------------------------------------------------
# NACL egress rule for HTTPS (via NAT)
#--------------------------------------------------------------------------------
resource "aws_network_acl_rule" "https" {
  count          = "${var.enable_nat == true ? 1 : 0}"
  network_acl_id = "${aws_network_acl.this.id}"
  rule_number    = 202
  egress         = true
  protocol       = "tcp"
  rule_action    = "${var.action}"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}
#--------------------------------------------------------------------------------
# NACL ingress rule for NAT gateway from public subnet to ephemeral ports.
#--------------------------------------------------------------------------------
resource "aws_network_acl_rule" "nat" {
  count          = "${var.enable_nat == true ? 1 : 0}"
  network_acl_id = "${aws_network_acl.this.id}"
  rule_number    = 203
  egress         = false
  protocol       = "tcp"
  rule_action    = "${var.action}"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}