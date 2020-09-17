#--------------------------------------------------------------------------------
# S3 prefix list
#--------------------------------------------------------------------------------
data "aws_prefix_list" "s3" {
  prefix_list_id = "${var.s3_prefix_list_id}"
}
#--------------------------------------------------------------------------------
# NACL egress rule to S3 URL.
# https://medium.com/@brad.simonin/create-an-aws-vpc-and-subnet-using-terraform-d3bddcbbcb6
# https://stackoverflow.com/questions/51206176/
#--------------------------------------------------------------------------------
resource "aws_network_acl_rule" "s3_out" {
  #count          = "${length(data.aws_prefix_list.s3.cidr_blocks)}"
  count          = "${var.enable_s3 == true ? length(data.aws_prefix_list.s3.cidr_blocks) : 0}"
  network_acl_id = "${aws_network_acl.this.id}"
  rule_number    = "${ 301 + count.index }"
  egress         = true
  protocol       = "tcp"
  rule_action    = "${var.action}"
  cidr_block     = "${element(data.aws_prefix_list.s3.cidr_blocks, count.index)}"
  from_port      = 443
  to_port        = 443
}
#--------------------------------------------------------------------------------
# NACL ingress rule from S3 URL.
#--------------------------------------------------------------------------------
resource "aws_network_acl_rule" "s3_in" {
  #count          = "${length(data.aws_prefix_list.s3.cidr_blocks)}"
  count          = "${var.enable_s3 == true ? length(data.aws_prefix_list.s3.cidr_blocks) : 0}"
  network_acl_id = "${aws_network_acl.this.id}"
  rule_number    = "${ 311 + count.index }"
  egress         = false
  protocol       = "tcp"
  rule_action    = "${var.action}"
  cidr_block     = "${element(data.aws_prefix_list.s3.cidr_blocks, count.index)}"
  from_port      = 1024
  to_port        = 65535
}


output "s3_cidr_count" {
  value = "${length(data.aws_prefix_list.s3.cidr_blocks)}"
}
output "s3_cidr" {
  value = "${data.aws_prefix_list.s3.cidr_blocks}"
}
