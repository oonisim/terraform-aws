variable "PROJECT" {
  default = "TBD"
}
variable "ENV" {
  default = "TBD"
}
variable "REGION" {
  default = "TBD"
}

#--------------------------------------------------------------------------------
# S3 bucket
# - To presign to upload the project data.
# - To upload packages e.g. lambda function packages
#--------------------------------------------------------------------------------
variable "bucket" {
  description = "TBD"
}

variable "api_gateway_rest_api_name" {
  description = "API name"
}
variable "api_gateway_rest_api_execution_arn" {
}
variable "api_gateway_authorization" {
  description = "Authorization repository"
  default = "COGNITO_USER_POOLS"
}
variable "api_gateway_authorizer_id" {
  description = "API Gateway authorizer ID"
}

variable "api_gateway_deployment_id" {
}
variable "api_gateway_deployment_stage_name" {

}
variable "api_gateway_deployment_rest_api_invoke_url" {
}

#--------------------------------------------------------------------------------
# [Cognito User Pool]
# Public keys of the region endpoint to decode Cocnito token to get user claims.
#--------------------------------------------------------------------------------
variable "cognito_userpool_id" {
  description = "Cognito User Pool id"
  default = "TBD"
}
variable "cognito_userpool_region" {
  description = "Cognito User Pool region"
  default = "TBD"
}
variable "cognito_userpool_client_id" {
  description = "Cognito User Pool appliation client id"
  default = "TBD"
}

#--------------------------------------------------------------------------------
# DynamoDB
#--------------------------------------------------------------------------------
variable "dynamo_table_name" {
  description = "job record table"
  default = "TBD"
}
variable "dynamo_table_region" {
  description = "DynamoDB region"
  default = "TBD"
}

#--------------------------------------------------------------------------------
# Kinesis stream
#--------------------------------------------------------------------------------
variable "kinesis_stream_name" {
  description = "Kinesis stream name"
}