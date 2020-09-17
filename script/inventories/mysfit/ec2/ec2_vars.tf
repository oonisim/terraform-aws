#--------------------------------------------------------------------------------
# Chat micro service
#--------------------------------------------------------------------------------
variable "ec2_ecs_service_keypair_public_key" {
  description = "EC2 keypair public key"
}

variable "ec2_ecs_service_instance_type" {
  description = "EC2 instance type"
  type = string
}
variable "ec2_ecs_service_volume_type" {
  description = "EBS volume type"
  type = string
}
variable "ec2_ecs_service_volume_size" {
  description = "EBS volume size"
  type = string
}
