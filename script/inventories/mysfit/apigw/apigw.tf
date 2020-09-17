#================================================================================
# API Gateway Private Integration to NLB
# https://docs.aws.amazon.com/apigateway/latest/developerguide/getting-started-with-private-integration.html
#================================================================================
resource "aws_api_gateway_vpc_link" "endpoint_microservice_XYZ" {
  name        = "${var.PROJECT}_${var.ENV}_${local.microservice_XYZ_name}"
  target_arns = [
    local.elb_arn
  ]
}

#================================================================================
# API for mysfit and click event stream
#================================================================================
resource "aws_api_gateway_rest_api" "mysfit" {
  name        = "${var.PROJECT}_${var.ENV}_${local.microservice_XYZ_name}"
  description = "API for ${local.microservice_XYZ_name}"
  body        = local_file.api_mysfit_swagger_json.content
}

resource "local_file" "api_mysfit_swagger_json" {
  content  = templatefile("${path.module}/aws-cli/api_mysfit_swagger.json.template", {
    REPLACE_ME_API_NAME             = replace("${title(var.PROJECT)}${title(var.ENV)}${title(local.microservice_XYZ_name)}", "/[-_.]/", "")
    REPLACE_ME_VPC_LINK_ID          = aws_api_gateway_vpc_link.endpoint_microservice_XYZ.id
    REPLACE_ME_NLB_DNS              = local.elb_dns_name
    REPLACE_ME_REGION               = var.REGION
    REPLACE_ME_ACCOUNT_ID           = data.aws_caller_identity.current.account_id
    REPLACE_ME_COGNITO_USER_POOL_ID = local.cognito_userpool_id
  })
  filename = "${path.module}/aws-cli/api_mysfit_swagger.json"
}

#--------------------------------------------------------------------------------
# Model
# Need to have a model pre-defined to use it. Otherwise error:
# Error creating API Gateway Method Response: BadRequestException: Invalid model identifier specified: Empty
#
# [Creating a model]
# Create a model with empty schema {}. Then you can select that model in method response.
# https://stackoverflow.com/questions/51602688/aws-api-gateway-no-options-for-models-in-method-response
#--------------------------------------------------------------------------------
resource "aws_api_gateway_model" "empty" {
  rest_api_id  = aws_api_gateway_rest_api.mysfit.id
  name         = "Empty"
  description  = "a JSON schema"
  content_type = "application/json"
  schema = <<EOF
{
}
EOF
}


# Exoise I/F
locals {
  aws_api_gateway_rest_api_mysfit_name = aws_api_gateway_rest_api.mysfit.name
  aws_api_gateway_rest_api_mysfit_id = aws_api_gateway_rest_api.mysfit.id
}