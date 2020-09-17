variable "name" {
  description = "Name of the NACL"
  type = string
}
variable "vpc_id" {
  type = string
}
variable "subnet_ids" {
  description = "Subnets to protect"
  type = list
}
variable "forign_cidr_blocks" {
  description = "List of forign CIDR against which NACL rules are defined"
  type = list
}
variable "action" {
  description = "allow or deny"
  type = string
}

variable "enable_nat" {
  description = "Flag to turn on nat rule"
  default     = true
}
variable "enable_mysql" {
  description = "Flag to turn on mysql rule (default port)"
  default     = false 
}
variable "enable_ssh" {
  description = "Flag to turn on ssh rule (default port)"
  default     = false
}
variable "enable_s3" {
  description = "Flag to turn on S3 endpoint rule)"
  default     = false
}
variable "s3_prefix_list_id" {
  description = "S3 prefix list ID"
}

variable "env" {
  type = string
}
variable "project" {
  type = string
}
