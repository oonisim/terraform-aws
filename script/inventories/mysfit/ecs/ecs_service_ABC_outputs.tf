output "aws_microservice_XYZ_name" {
  value = "${module.ecs_service_ABC.aws_ecs_service_name}"
}
output "aws_microservice_XYZ_id" {
  value = "${module.ecs_service_ABC.aws_ecs_service_id}"
}
output "aws_microservice_XYZ_arn" {
  value = "${module.ecs_service_ABC.aws_ecs_service_arn}"
}
output "aws_microservice_XYZ_iam_role_arn" {
  value = "${module.ecs_service_ABC.aws_ecs_service_iam_role_arn}"
}
output "aws_microservice_XYZ_launch_type" {
  value = "${module.ecs_service_ABC.aws_ecs_service_launch_type}"
}
output "aws_microservice_XYZ_load_balancer" {
  value = "${module.ecs_service_ABC.aws_ecs_service_load_balancer}"
}
output "aws_microservice_XYZ_task_definition" {
  value = "${module.ecs_service_ABC.aws_ecs_service_task_definition}"
}
output "aws_microservice_XYZ_XYZ_desired_count" {
  value = "${module.ecs_service_ABC.aws_ecs_service_desired_count}"
}
