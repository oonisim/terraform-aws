#--------------------------------------------------------------------------------
# API proxy resource to match path parameters.
# https://stackoverflow.com/questions/39040739/in-terraform-how-do-you-specify-an-api-gateway-endpoint-with-a-variable-in-the
# https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-method-settings-method-request.html
# https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-set-up-simple-proxy.html
# For the PetStore API example, you can use /{proxy+} to represent both the /pets and /pets/{petId}.
# You can configure a specific HTTP method on a greedy resource or apply non-proxy integration types to a proxy resource.
#
# [Problem]
# Another resource with the same parent already has this name: {jobid+}
# -> Change {jobid+} into something else e.g. {hoge+}, re-run. THen change back & re-run.
#--------------------------------------------------------------------------------
resource "aws_api_gateway_resource" "jobid" {
  rest_api_id = local.rest_api_id
  parent_id   = aws_api_gateway_resource.job.id

  #--------------------------------------------------------------------------------
  # {job_id+} causes an error.
  # Make sure the 'jobid' string matches in the pathParameter value check logic
  # in the lambda function intergrated.
  #--------------------------------------------------------------------------------
  path_part = "{jobid+}"
}

# Method represents an interface of the object (resource)
resource "aws_api_gateway_method" "jobid_get" {
  rest_api_id   = local.rest_api_id
  resource_id   = aws_api_gateway_resource.jobid.id
  http_method   = "GET"
  authorization = local.api_authorization_type
  authorizer_id = local.api_authorizer_id
  request_parameters = {
    "method.request.path.jobid" = false
  }
}

resource "aws_api_gateway_integration" "jobid_get" {
  rest_api_id = local.rest_api_id
  resource_id = aws_api_gateway_method.jobid_get.resource_id
  http_method = aws_api_gateway_method.jobid_get.http_method

  #--------------------------------------------------------------------------------
  # Lambda Proxy integration (AWS_PROXY) integration method MUST be POST.
  # https://stackoverflow.com/questions/41371970
  #--------------------------------------------------------------------------------
  integration_http_method = "POST"

  #--------------------------------------------------------------------------------
  type = "AWS_PROXY" # Lambda Proxy
  uri  = local.lambda_monitor_invoke_arn

  #--------------------------------------------------------------------------------
  # Make sure the 'jobid' string matches in that of aws_api_gateway_resource
  #--------------------------------------------------------------------------------
  request_parameters = {
    "integration.request.path.id" = "method.request.path.jobid"
  }

  depends_on = [
    "aws_api_gateway_integration.job_post"
  ]

}

# Method represents an interface of the object (resource)
resource "aws_api_gateway_method" "jobid_delete" {
  rest_api_id   = local.rest_api_id
  resource_id   = aws_api_gateway_resource.jobid.id
  http_method   = "DELETE"
  authorization = local.api_authorization_type
  authorizer_id = local.api_authorizer_id
  request_parameters = {
    "method.request.path.jobid" = false
  }
}

resource "aws_api_gateway_integration" "jobid_delete" {
  rest_api_id = local.rest_api_id
  resource_id = aws_api_gateway_method.jobid_delete.resource_id
  http_method = aws_api_gateway_method.jobid_delete.http_method

  #--------------------------------------------------------------------------------
  # Lambda Proxy integration (AWS_PROXY) integration method MUST be POST.
  # https://stackoverflow.com/questions/41371970
  #--------------------------------------------------------------------------------
  integration_http_method = "POST"

  #--------------------------------------------------------------------------------
  type = "AWS_PROXY" # Lambda Proxy
  uri  = local.lambda_delete_invoke_arn

  #--------------------------------------------------------------------------------
  # Make sure the 'jobid' string matches in that of aws_api_gateway_resource
  #--------------------------------------------------------------------------------
  request_parameters = {
    "integration.request.path.id" = "method.request.path.jobid"
  }
  depends_on = [aws_api_gateway_method.jobid_delete]
}

#--------------------------------------------------------------------------------
# CORS for the API resource
# OPTIONS method is required for CORS
# API Gateway URL domain can be different from that of the web domain.
# https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-cors.html
# https://medium.com/@MrPonath/terraform-and-aws-api-gateway-a137ee48a8ac
# https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-mock-integration.html
#
# TODO
# Limit the domain to those to the project DNS names in Access-Control-Allow-Origin header.
#--------------------------------------------------------------------------------
resource "aws_api_gateway_method" "jobid_options" {
  rest_api_id   = local.rest_api_id
  resource_id   = aws_api_gateway_resource.jobid.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "jobid_options" {
  rest_api_id = local.rest_api_id
  resource_id = aws_api_gateway_resource.jobid.id
  http_method = aws_api_gateway_method.jobid_options.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
  depends_on = [aws_api_gateway_method.jobid_options]
}

resource "aws_api_gateway_integration" "jobid_options" {
  rest_api_id = local.rest_api_id
  resource_id = aws_api_gateway_resource.jobid.id
  http_method = aws_api_gateway_method.jobid_options.http_method
  type        = "MOCK"

  #--------------------------------------------------------------------------------
  # OPTIONS must reply {"statusCode": 200}
  # https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-mock-integration.html
  #--------------------------------------------------------------------------------
  request_templates = {
    "application/json" = "{'statusCode': 200}"
  }

  depends_on  = [aws_api_gateway_method.jobid_options]
}

resource "aws_api_gateway_integration_response" "jobid_options" {
  rest_api_id = local.rest_api_id
  resource_id = aws_api_gateway_resource.jobid.id
  http_method = aws_api_gateway_method.jobid_options.http_method
  status_code = aws_api_gateway_method_response.jobid_options.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT,DELETE'"
    #--------------------------------------------------------------------------------
    # Need to limit to the project domain names
    #--------------------------------------------------------------------------------
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.jobid_options]
}

