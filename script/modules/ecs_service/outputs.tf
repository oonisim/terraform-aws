output "aws_ecs_service_name" {
  value = "${aws_ecs_service.this.name}"
}
output "aws_ecs_service_id" {
  value = "${aws_ecs_service.this.id}"
}
output "aws_ecs_service_arn" {
  value = "${aws_ecs_service.this.id}"
}
output "aws_ecs_service_iam_role_arn" {
  value = "${aws_ecs_service.this.iam_role}"
}
output "aws_ecs_service_launch_type" {
  value = "${aws_ecs_service.this.launch_type}"
}
output "aws_ecs_service_load_balancer" {
  value = "${aws_ecs_service.this.load_balancer}"
}
output "aws_ecs_service_task_definition" {
  value = "${aws_ecs_service.this.task_definition}"
}
output "aws_ecs_service_desired_count" {
  value = "${aws_ecs_service.this.desired_count}"
}
