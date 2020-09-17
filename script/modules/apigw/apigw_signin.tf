#--------------------------------------------------------------------------------
# API resource (an object representing feature/function of a business, e.g. HR payroll)
#--------------------------------------------------------------------------------
resource "aws_api_gateway_resource" "signin" {
  rest_api_id = local.rest_api_id
  parent_id   = local.rest_api_current_resource_id
  path_part   = var.api_gateway_resource_signin_path
}

# Method represents an interface of the object (resource)
resource "aws_api_gateway_method" "signin_get" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.signin.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "signin_get" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_method.signin_get.resource_id
  http_method = aws_api_gateway_method.signin_get.http_method

  /*
  request_templates = {                  # Not documented
    "application/json" = "${file("${path.module}/${var.apigw_signin_mapping_template_json}")}"
  }
  */
  #--------------------------------------------------------------------------------
  # Lambda Proxy integration (AWS_PROXY) integration method MUST be POST.
  # https://stackoverflow.com/questions/41371970
  #--------------------------------------------------------------------------------
  #integration_http_method = "GET"
  integration_http_method = "POST"

  #--------------------------------------------------------------------------------
  type = "AWS_PROXY" # Lambda Proxy

  #type                    = "AWS"  # Lambda Proxy
  uri = local.lambda_signin_invoke_arn

  depends_on = [
    "aws_api_gateway_integration.ping_get"
  ]
}

#--------------------------------------------------------------------------------
# CORS
# OPTIONS method is required for CORS
# API Gateway URL domain can be different from that of the web domain.
# https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-cors.html
# https://medium.com/@MrPonath/terraform-and-aws-api-gateway-a137ee48a8ac
# https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-mock-integration.html
#
# TODO
# Limit the domain to those to the project DNS names in Access-Control-Allow-Origin header.
#--------------------------------------------------------------------------------
resource "aws_api_gateway_method" "signin_options" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.signin.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "signin_options" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.signin.id
  http_method = aws_api_gateway_method.signin_options.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
  depends_on = [aws_api_gateway_method.signin_options]
}

resource "aws_api_gateway_integration" "signin_options" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.signin.id
  http_method = aws_api_gateway_method.signin_options.http_method
  type        = "MOCK"

  #--------------------------------------------------------------------------------
  # OPTIONS must reply {"statusCode": 200}
  # https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-mock-integration.html
  #--------------------------------------------------------------------------------
  request_templates = {
    "application/json" = "{'statusCode': 200}"
  }

  depends_on  = [aws_api_gateway_method.signin_options]

}

resource "aws_api_gateway_integration_response" "signin_options" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.signin.id
  http_method = aws_api_gateway_method.signin_options.http_method
  status_code = aws_api_gateway_method_response.signin_options.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'"
    #--------------------------------------------------------------------------------
    # Need to limit to the project domain names
    #--------------------------------------------------------------------------------
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.signin_options]
}

