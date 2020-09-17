#--------------------------------------------------------------------------------
# Setting Up CloudWatch API Logging in API Gateway
# https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-logging.html
# https://www.terraform.io/docs/providers/aws/r/api_gateway_stage.html#access_log_settings-1
#--------------------------------------------------------------------------------
variable "enable_apigw_stage_cloudwatch_access_log" {
  type = bool
  default = false
}
variable "apigw_stage_cloudwatch_access_loggroup_name" {
  description = "CloudWatch loggroup name. null if not using"
  type = string
  default = null
}
variable "apigw_stage_cloudwatch_access_loggroup_format" {
  description = "CloudWatch loggroup format"
  type = string
  default = "JSON"
}
variable "xray_tracing_enabled" {
  description = "Flag to enable|disable X-ray. Default false"
}
