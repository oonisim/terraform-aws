#--------------------------------------------------------------------------------
# ECS service
#--------------------------------------------------------------------------------
variable "ecs_service_launch_type" {
  description = "How ECS launch instances. EC2 or FARGATE"
  default = "EC2"
}
# TODO: Use the global parameter service name
/*
variable "ecs_service_desired_count" {
  #--------------------------------------------------------------------------------
  # The number of instantiations of the specified task definition (=docker image) running.
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service_definition_parameters.html
  #--------------------------------------------------------------------------------
  description = "The number of containers to run for the service."
}

variable "ecs_service_name" {
  description = "Service"
}
variable "ecs_healthcheck_grace_period_seconds" {
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown"
  default = 0
}

# Container port mapping
variable "ecs_service_container_port" {
  description = "Port in the container to be exposed"
}
variable "ecs_service_host_port" {
  description = "EC2 instance port to expose the container service for LB target group. Must match with the LB configuration"
}
*/
