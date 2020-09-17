#--------------------------------------------------------------------------------
# ASG EC2 instance protocol/port for SG
#--------------------------------------------------------------------------------

# TODO: Incorporate multiple containers in an ECS task
/*
variable "ec2_microservice_XYZ_host_port" {
  description = "EC2 incoming port from the LB for the API"
}
variable "ec2_microservice_XYZ_protocol" {
  description = "Protocol for the API"
}
variable "ec2_sg_microservice_XYZ_external_client_cidr_blocks" {
  description = "CIDR blocks for EC2 SG ingress to accept client connections"
}
variable "ec2_microservice_XYZ_healthcheck_host_port" {
  description = "EC2 incoming port for the health check from ELB"
}
variable "ec2_microservice_XYZ_healthcheck_protocol" {
  description = "Protocol for the health check from ELB"
}
*/
variable "lc_ecs_cluster_ssh_port" {
  description = "EC2 incoming port from the public subnets for SSH"
}
variable "lc_ecs_cluster_ssh_protocol" {
  description = "Protocol for SSH"
}