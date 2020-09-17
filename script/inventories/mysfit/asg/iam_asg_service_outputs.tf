#--------------------------------------------------------------------------------
# ECS EC2 IAM
#--------------------------------------------------------------------------------
output "ec2_ecs_service_profile_name" {
  value = local.ec2_ecs_service_instance_profile_name
}
output "ecs_ecs_profile_iam_role_arn" {
  value = aws_iam_role.ec2_ecs_service.arn
}
