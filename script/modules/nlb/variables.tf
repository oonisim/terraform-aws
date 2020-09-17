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
    tags = {
      Project = var.PROJECT
      Env     = var.ENV
    }
  },
  */
}
variable "enable_access_logs" {
  description = "Flag to enable LB access logging"
}

variable "enable_health_check" {
  description = "flag to enable health check"
#  default = true
}

variable "tags" {
  type = map(string)
}

variable "enable_lb_stickiness" {
  description = "Flag to enable loadbalancer stickiness (cookie)"
  type = bool
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

