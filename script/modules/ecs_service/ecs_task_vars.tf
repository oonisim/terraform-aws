#--------------------------------------------------------------------------------
# ECS task (docker container runtime) parameters
#--------------------------------------------------------------------------------
variable "ecs_task_container_definition_template_path" {
  description = "ECS container definition JSON file path (from module root)"
  type = string
  default = "container_definitions/ecs_task_container_definition.json.template"
}
variable "ecs_task_container_definition_path" {
  description = "ECS container definition JSON file path (from module root)"
  type = string
  default = "container_definitions/ecs_task_container_definition.json"
}

#--------------------------------------------------------------------------------
# ECS task
#--------------------------------------------------------------------------------
variable "ecs_task_name" {
  description = "Name of the ECS task"
  type = string
}
variable "ecs_task_network_mode" {
  description = "(Optional) The Docker networking mode to use for the containers in the task. The valid values are none, bridge, awsvpc, and host"
  type = string
  default = "bridge"
}

variable "ecs_task_cpu_units" {
  description = "CPU units to allocate to container"
  default = 256
}

variable "ecs_task_memory_units" {
  description = "Memory units to allocate to container"
  default = 256
}

variable "ecs_task_port_mappings" {
  description = "container port mappings"
  type = list
}

#--------------------------------------------------------------------------------
# Container
#--------------------------------------------------------------------------------
variable "container_image_url" {
  description = "Location of the docker image to be deplyed as the ECS task"
  type = string
}
variable "container_name" {
  description = "The name of the service that the Docker container provides"
  type = string
}
variable "container_port" {
  description = "The port of the Docker container"
  type = number
}
