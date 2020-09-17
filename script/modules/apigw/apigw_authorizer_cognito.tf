#--------------------------------------------------------------------------------
# https://auth0.com/docs/integrations/aws-api-gateway/custom-authorizers/part-3#prepare-the-custom-authorizer
#--------------------------------------------------------------------------------
data "aws_cognito_user_pools" "this" {
  name = var.identity_provider_name
}

resource "aws_api_gateway_authorizer" "this" {
  name                   = "authorizer"
  rest_api_id            = aws_api_gateway_rest_api.this.id
  type                   = var.identity_authorization_type
  provider_arns          = data.aws_cognito_user_pools.this.arns
  authorizer_credentials = aws_iam_role.api_gateway_auth_invocation.arn

  #identity_validation_expression   = "${var.authorizer_identity_validation_expression}"
  authorizer_result_ttl_in_seconds = var.authorizer_result_ttl_in_seconds
}

