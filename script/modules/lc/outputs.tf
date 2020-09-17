output "aws_launch_configuration_keypair_name" {
  value = "${aws_key_pair.this.key_name}"
}
output "aws_launch_configuration_keypair_id" {
  value = "${aws_key_pair.this.id}"
}
output "aws_launch_configuration_image_id" {
  value = "${aws_launch_configuration.this.image_id}"
}
output "aws_launch_configuration_id" {
  value = "${aws_launch_configuration.this.id}"
}
output "aws_launch_configuration_name" {
  value = "${aws_launch_configuration.this.name}"
}
output "aws_launch_configuration_user_data" {
  value = "${aws_launch_configuration.this.user_data}"
}
output "aws_launch_configuration_user_security_groups" {
  value = "${aws_launch_configuration.this.security_groups}"
}

