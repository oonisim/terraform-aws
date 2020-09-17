#--------------------------------------------------------------------------------
# EC2 keypair
#--------------------------------------------------------------------------------
resource "aws_key_pair" "this" {
  key_name   = "${var.PROJECT}_${var.ENV}_${var.name}"
  public_key = "${var.keypair_public_key}"
}

#--------------------------------------------------------------------------------
# launch configuration
#--------------------------------------------------------------------------------
resource "aws_launch_configuration" "this" {
  # To avoid Error creating launch configuration: AlreadyExists
  name_prefix       = "${var.PROJECT}_${var.ENV}_${var.name}"

  key_name          = "${aws_key_pair.this.key_name}"
  image_id          = "${var.ami_id}"
  instance_type     = "${var.instance_type}"
  iam_instance_profile = "${var.iam_instance_profile}"

  security_groups   = "${var.security_group_ids}"

  user_data         = "${var.user_data}"

  root_block_device {
    volume_type = "${var.root_volume_type}"
    volume_size = "${var.root_volume_size}"
    delete_on_termination = true
  }

  spot_price = var.spot_price

  lifecycle {
    create_before_destroy = true
  }
}
