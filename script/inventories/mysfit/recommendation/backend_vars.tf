
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

variable "backend_key_s3" {
  description = "S3 backend key to common component"
  default     = "s3.tfstate"
}


variable "backend_key_vpc" {
  description = "S3 backend key to VPC component"
  default     = "vpc.tfstate"
}

variable "backend_key_kinesis_firehose" {
  description = "S3 backend key to kinesis firehose component"
  default     = "kinesis_firehose.tfstate"
}

variable "backend_key_apigw" {
  description = "S3 backend key to kinesis apigw component"
  default     = "apigw.tfstate"
}

variable "backend_key_sagemaker" {
  description = "S3 backend key to kinesis apigw component"
  default     = "sagemaker.tfstate"
}