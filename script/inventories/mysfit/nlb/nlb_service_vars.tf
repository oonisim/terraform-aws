/*
variable "nlb_microservice_XYZ_name" {
  description = "Load balancer name for the service"
}
variable "nlb_listeners_for_ecs_service_ABC" {
  description = "Load balancer listeners"
  type = list
}
variable "nlb_target_groups_for_ecs_service_ABC" {
  description = "targets of aws_lb_target_group"
  type = list
   List of maps in the format below
    {
    #--------------------------------------------------------------------------------
    # Name is used to identify the target group and set to the name_prefix to avoid
    # TF issue of "resource already exists".
    # Max length is 6 due to the TF limitation.
    # https://www.terraform.io/docs/providers/aws/r/lb_target_group.html#name_prefix
    #--------------------------------------------------------------------------------
    name = "TBD"
    #--------------------------------------------------------------------------------
    target_type = "ip"
    port = 80
    protocol = "HTTP"
    stickiness = true
  },
}
*/

variable "enable_health_check" {
  description = "Flat to enable LB health check"
  type = bool
}
variable "enable_lb_stickiness" {
  description = "Flag to enable loadbalancer stickiness (cookie)"
  type = bool
}
variable "nlb_enable_access_logs" {
  description = "Flag to enable LB access logging"
  type = bool
}
