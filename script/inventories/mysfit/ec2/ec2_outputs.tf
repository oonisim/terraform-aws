#--------------------------------------------------------------------------------
# ECS EC2 instance
#--------------------------------------------------------------------------------
output "ecs_ec2_instance_ids" {
  value = aws_instance.ecs[*].id
}
# Only have private IPs
output "ecs_ec2_instance_private_ips" {
  value = aws_instance.ecs[*].private_ip
}

