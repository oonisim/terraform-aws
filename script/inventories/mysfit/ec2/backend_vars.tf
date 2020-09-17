#--------------------------------------------------------------------------------
# Injected via run.sh using TF_VAR_ mechanism
#--------------------------------------------------------------------------------
variable "BACKEND_BUCKET" {
}

variable "BACKEND_KEY" {
}
#--------------------------------------------------------------------------------


variable "backend_key_common" {
  description = "S3 backend key to common component"
  default     = "common.tfstate"
}
variable "backend_key_vpc" {
  description = "S3 backend key to VPC component"
  default     = "vpc.tfstate"
}
variable "backend_key_s3" {
  description = "S3 backend key to s3 component"
  default     = "s3.tfstate"
}
variable "backend_key_lb" {
  description = "S3 backend key to lb component. Choose alb or nlb"
  #--------------------------------------------------------------------------------
  # NLB can cause issues. Especially dynamic port mapping for which the ECS task
  # creation clearlly specify ALB to use.
  # https://stackoverflow.com/questions/60085717
  #--------------------------------------------------------------------------------
  default     = "nlb.tfstate"
}
variable "backend_key_ecs" {
  description = "S3 backend key to ecs component."
  default     = "ecs.tfstate"
}
