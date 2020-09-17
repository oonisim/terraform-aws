variable "PROJECT" {
}

variable "ENV" {
}

variable "REGION" {
}

#--------------------------------------------------------------------------------
# Load balancer
#--------------------------------------------------------------------------------
variable "name" {
  description = "Load balancer name"
}
variable "is_internal" {
  type = bool
  description = "Flag if the load balancer is internal"
  default = false
}
variable "security_group_ids" {
  description = "Load balancer security group IDs"
  type = list
}
variable "listeners" {
  description = "Load balancer listeners"
  type = list
  /* List of maps in the format below
    {
      port = 80
      protocol = "HTTP"
      action = "forward"
    }
  */
}
variable "targets" {
  description = "targets of aws_lb_target_group"
  type = list
  /* List of maps in the format below
    {
    target_type = "ip"
    port = 80
    protocol = "HTTP"
    stickiness = true
  },
  */
}

variable "tags" {
  type = map(string)
}

#--------------------------------------------------------------------------------
# VPC
#--------------------------------------------------------------------------------
variable "vpc_id" {
  description = "VPC ID in which to run the instances"
}
variable "subnet_ids" {
  description = "VPC subnet IDs to palce the load balancer in"
  type = list
}

#--------------------------------------------------------------------------------
# S3 for log
# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html
#--------------------------------------------------------------------------------
variable "bucket_log_name" {
  description = "S3 bucket for load balancer log"
}

variable "enable_access_logs" {
  description = "Flag to enable LB access logging"
}
