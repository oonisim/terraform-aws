#--------------------------------------------------------------------------------
# EC2 keypair
#--------------------------------------------------------------------------------
resource "aws_key_pair" "this" {
  key_name   = "${var.PROJECT}_${var.ENV}_${var.name}"
  public_key = "${var.keypair_public_key}"
}

resource "aws_instance" "this" {
  ami = "${local.ami_this_id}"
  instance_type = "${var.instance_type}"
  subnet_id = "${var.subnet_id}"
  vpc_security_group_ids = [
    "${aws_security_group.this.id}"
  ]
  key_name = "${aws_key_pair.this.key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.this.id}"

  user_data = "${local.user_data}"

  root_block_device {
    volume_type = "${var.root_volume_type}"
    volume_size = "${var.root_volume_size}"
    delete_on_termination = true
  }
}