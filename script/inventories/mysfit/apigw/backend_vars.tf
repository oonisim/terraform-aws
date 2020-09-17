
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

variable "backend_key_cognito_idp" {
  description = "S3 backend key to Cognito User Pool component"
  default     = "cognito_idp.tfstate"
}
/*
variable "backend_key_kinesis_firehose" {
  description = "S3 backend key to kinesis firehose component"
  default     = "kinesis_firehose.tfstate"
}

variable "backend_key_questionnaire" {
  description = "S3 backend key to Cognito User Pool component"
  default     = "questionnaire.tfstate"
}

variable "backend_key_recommendation" {
  description = "S3 backend key to Cognito User Pool component"
  default     = "recommendation.tfstate"
}
*/