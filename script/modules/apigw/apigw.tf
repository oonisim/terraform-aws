#--------------------------------------------------------------------------------
# API configuration for the account
#--------------------------------------------------------------------------------
resource "aws_api_gateway_account" "this" {
  cloudwatch_role_arn = aws_iam_role.apigateway.arn
}

#--------------------------------------------------------------------------------
# API (represents biz)
#--------------------------------------------------------------------------------
resource "aws_api_gateway_rest_api" "this" {
  name        = var.api_name
  description = var.api_description
}

#--------------------------------------------------------------------------------
# API root path '/'
#--------------------------------------------------------------------------------
resource "aws_api_gateway_resource" "root" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = var.api_path
}

#--------------------------------------------------------------------------------
# API version path
#--------------------------------------------------------------------------------
resource "aws_api_gateway_resource" "current" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.root.id
  path_part   = var.api_version
}

