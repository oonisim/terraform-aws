variable "PROJECT" {
}

variable "ENV" {
}

variable "REGION" {
}

variable "name" {
  description = "LC name"
}

#--------------------------------------------------------------------------------
# EC2
#--------------------------------------------------------------------------------
variable "keypair_public_key" {
  description = "EC2 keypair public key"
}
variable "ami_id" {
  description = "AMI image ID"
}
variable "instance_type" {

}
variable "root_volume_type" {}
variable "root_volume_size" {}
variable "user_data" {}
variable "iam_instance_profile" {
  description = "EC2 profile."
}

variable "spot_price" {
  description = "ASG EC2 spot price"
  default = "" # an empty string which means the on-demand price.
}

#--------------------------------------------------------------------------------
# SG
#--------------------------------------------------------------------------------
variable "security_group_ids" {
  description = "EC2 security group"
}
