/*
variable "alb_ecs_service_ABC_name" {
  description = "Load balancer name for the service"
}

variable "alb_listeners_for_ecs_service_ABC" {
  description = "Load balancer listeners"
  type = list
}
variable "alb_target_groups_for_ecs_service_ABC" {
  description = "targets of aws_lb_target_group"
  type = list
}
*/
variable "alb_enable_access_logs" {
  description = "Flag to enable LB access logging"
}
