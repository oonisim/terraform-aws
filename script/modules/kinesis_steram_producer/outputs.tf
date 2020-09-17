#--------------------------------------------------------------------------------
# API Gateway and authorizer testing URLs
#--------------------------------------------------------------------------------
# URL to upload the API gateway to test its availability.
output "api_gateway_lambda_kinesis_producer_url" {
  value = "${local.api_gateway_kinesis_producer_url}"
}