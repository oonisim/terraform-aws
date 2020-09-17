output "ec2_instance_id" {
  value = "${aws_instance.this.id}"
}

output "ec2_ami_id" {
  value = "${local.ami_this_id}"
}

output "ec2_userdata" {
  value = "${local.user_data}"
}

output "ec2_keypair_name" {
  value = "${aws_key_pair.this.key_name}"
}

output "ec2_public_ip" {
  value = "${aws_instance.this.public_ip}"
}

output "ec2_public_dns" {
  value = "${aws_instance.this.public_dns}"
}

output "ec2_security_group_ids" {
  value = "${aws_instance.this.security_groups}"
}

output "ec2_instance_role_arn" {
  value = "${aws_iam_role.ec2_instance_profile.arn}"
}

output "ec2_instance_profile_id" {
  value = "${aws_iam_instance_profile.this.id}"
}