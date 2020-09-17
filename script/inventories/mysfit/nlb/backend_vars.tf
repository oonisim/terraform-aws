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
