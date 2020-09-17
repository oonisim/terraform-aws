output "sg_alb_for_ecs_service_ABC_id" {
  value = aws_security_group.alb_ecs_service_ABC.id
}
output "sg_alb_for_ecs_service_ABC_ingress" {
  value = aws_security_group.alb_ecs_service_ABC.ingress
}
output "sg_alb_for_ecs_service_ABC_engress" {
  value = aws_security_group.alb_ecs_service_ABC.egress
}