#--------------------------------------------------------------------------------
# NACL for this subnet
#--------------------------------------------------------------------------------
resource "aws_network_acl" "this" {
  vpc_id         = "${var.vpc_id}"
  subnet_ids     = [ "${var.subnet_ids}" ]

  tags = {
    Name        = "${var.name}"
    Environment = "${var.env}"
    Project     = "${var.project}"
  }
}
