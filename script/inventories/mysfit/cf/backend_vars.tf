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

variable "backend_key_cognito_idp" {
  description = "S3 backend key to Cognito User Pool component"
  default     = "cognito_idp.tfstate"
}

variable "backend_key_apigw" {
  description = "S3 backend key to API GW component"
  default     = "apigw.tfstate"
}

variable "backend_key_userevent" {
  description = "S3 backend key to click event component"
  default     = "userevent.tfstate"
}

variable "backend_key_questionnaire" {
  description = "S3 backend key to question component"
  default     = "questionnaire.tfstate"
}

variable "backend_key_recommendation" {
  description = "S3 backend key to recommendation component"
  default     = "recommendation.tfstate"
}
