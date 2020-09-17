#================================================================================
# Configure the AWS Provider
#================================================================================
/*
variable "REGION" {
  description = "The target AWS region"
  type        = "string"
  #default     = "southeast-2"
}
*/
#--------------------------------------------------------------------------------
# Project Variables
#--------------------------------------------------------------------------------
variable "PROJECT" {
  description = "The name of the environment. e.g (dev, sit, prod)"
  type        = "string"
}

variable "ENV" {
  description = "The name of the environment. e.g (dev, sit, prod)"
  type        = "string"
  #default     = "dev"
}

#--------------------------------------------------------------------------------
# Network Variables
#--------------------------------------------------------------------------------
variable "vpc_id" {
  description   = "The ID of the VPC that the RDS cluster will be created in"
  type          = "string"
}

variable "vpc_name" {
  description = "The name of the VPC that the RDS cluster will be created in"
  type          = "string"
}

variable "subnet_ids" {
  description = "The ID's of the VPC subnets that the RDS cluster instances will be created in"
  type    = "string"
}

variable "security_group_id" {
  description = "The ID of the security group that should be used for the RDS cluster instances"
  type          = "string"
}

#--------------------------------------------------------------------------------
# RDS Cluster Variables
#--------------------------------------------------------------------------------
variable "username" {
  description = "The master database username to login to the RDS cluster."
}

variable "password" {
  description = "The password for the master database user to login to the RDS cluster."
}

variable "retention_period" {
  description = "The database backup retention period."
  #default     = 7
}

variable "db_instance_class" {
  description = "The name of the database."
  type        = "string"
  #default     = "db.t2.small"
}

variable "db_name" {
  description = "The name of the database."
  type        = "string"
  #default     = "TEST"
}

variable "db_engine" {
  description = "The engine of the database."
  type        = "string"
  #default     = "aurora"
}

variable "db_port" {
  description = "The engine of the database."
  #default     = 3306
}

