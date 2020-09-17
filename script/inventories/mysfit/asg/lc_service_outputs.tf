output "keypair_name" {
  value = "${module.lc_ecs_cluster.aws_launch_configuration_keypair_name}"
}
output "keypair_id" {
  value = "${module.lc_ecs_cluster.aws_launch_configuration_keypair_id}"
}
output "aws_launch_configuration_image_id" {
  value = "${module.lc_ecs_cluster.aws_launch_configuration_image_id}"
}
output "aws_launch_configuration_id" {
  value = "${module.lc_ecs_cluster.aws_launch_configuration_id}"
}
output "aws_launch_configuration_name" {
  value = "${module.lc_ecs_cluster.aws_launch_configuration_name}"
}
output "aws_launch_configuration_user_data" {
  value = "${module.lc_ecs_cluster.aws_launch_configuration_user_data}"
}
output "aws_launch_configuration_user_security_groups" {
  value = "${module.lc_ecs_cluster.aws_launch_configuration_user_security_groups}"
}
