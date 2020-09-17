#================================================================================
# API "question" resource and POST method to recieve questions from the users.
# Use LAMBDA_PROXY (AWS_PROXY) integration which requires no difinition of
# both method response and integration response for the POST method.
# https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-method-settings-method-response.html
# https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-integration-settings-integration-response.html
#================================================================================
/*
swagger: 2.0
info:
  title:
    Ref: AWS::StackName
paths:
  "/questions":
    post:
      consumes:
        - 'application/json'
      produces:
        - 'application/json'
      responses:
        '200':
          statusCode: 200
          headers:
            Access-Control-Allow-Headers:
                type: string
            Access-Control-Allow-Methods:
                type: string
            Access-Control-Allow-Origin:
                type: string
      x-amazon-apigateway-integration:
        responses:
          default:
            statusCode: 200
            responseParameters:
              method.response.header.Access-Control-Allow-Headers: "'Content-Type'"
              method.response.header.Access-Control-Allow-Methods: "'OPTIONS, POST'"
              method.response.header.Access-Control-Allow-Origin: "'*'"
        credentials: !GetAtt QuestionsApiRole.Arn
        httpMethod: POST
        type: aws_proxy
        uri: !Join ["", ["arn:aws:apigateway:", { "Ref": "AWS::Region" }, ":lambda:path/2015-03-31/functions/", !GetAtt MysfitsPostQuestionFunction.Arn, "/invocations" ] ]
*/
#--------------------------------------------------------------------------------
# Get the mysfit rest API and root resource
#--------------------------------------------------------------------------------
data "aws_api_gateway_rest_api" "mysfit" {
  name = local.api_gateway_rest_api_name
}

data "aws_api_gateway_resource" "root" {
  rest_api_id = data.aws_api_gateway_rest_api.mysfit.id
  path        = "/"
}

#--------------------------------------------------------------------------------
# API resource for Mysfit `questions`
#--------------------------------------------------------------------------------
resource "aws_api_gateway_resource" "question" {
  rest_api_id = data.aws_api_gateway_rest_api.mysfit.id
  parent_id   = data.aws_api_gateway_rest_api.mysfit.root_resource_id
  path_part   = var.api_gateway_resource_question_path
}

#--------------------------------------------------------------------------------
# Client is sending a question with POST HTTP request with JSON body.
#
#$.ajax({
#  url : questionsApi,
#  type : 'POST',
#  headers : {'Content-Type': 'application/json'},
#  dataType: 'json',
#  data : JSON.stringify(questionnaireEntry),
#});
#--------------------------------------------------------------------------------
resource "aws_api_gateway_method" "question_post" {
  rest_api_id   = data.aws_api_gateway_rest_api.mysfit.id
  resource_id   = aws_api_gateway_resource.question.id
  http_method   = "POST"
  # TODO: Implment authorization
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "question_post" {
  rest_api_id = data.aws_api_gateway_rest_api.mysfit.id
  resource_id = aws_api_gateway_resource.question.id

  type                    = "AWS_PROXY"
  http_method             = aws_api_gateway_method.question_post.http_method
  integration_http_method = "POST"
  uri                     = local.lambda_receive_question_invoke_arn
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
resource "aws_api_gateway_method" "question_options" {
  rest_api_id   = data.aws_api_gateway_rest_api.mysfit.id
  resource_id   = aws_api_gateway_resource.question.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "question_options" {
  rest_api_id = data.aws_api_gateway_rest_api.mysfit.id
  resource_id = aws_api_gateway_resource.question.id
  http_method = aws_api_gateway_method.question_options.http_method
  type        = "MOCK"

  #--------------------------------------------------------------------------------
  # OPTIONS must reply {"statusCode": 200}
  # https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-mock-integration.html
  #--------------------------------------------------------------------------------
  request_templates = {
    "application/json" = "{'statusCode': 200}"
  }

  depends_on = [
    aws_api_gateway_method.question_options
  ]
}

#--------------------------------------------------------------------------------
# method_response must exist before creating integration response.
# Otherwise error:
# Invalid mapping expression specified: Validation Result: warnings : [], errors : [No method response exists for method.]
#--------------------------------------------------------------------------------
resource "aws_api_gateway_method_response" "question_options_200" {
  rest_api_id = data.aws_api_gateway_rest_api.mysfit.id
  resource_id = aws_api_gateway_resource.question.id
  http_method = aws_api_gateway_method.question_options.http_method
  status_code = "200"

  #--------------------------------------------------------------------------------
  # [Model for method response]
  # Model resources used for the response's content-type.
  # Response models are key/value maps; ontent-type as the key and a Model name as value.
  # https://docs.aws.amazon.com/apigateway/api-reference/resource/method-response/
  #--------------------------------------------------------------------------------
  response_models     = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  depends_on          = [
    aws_api_gateway_integration.question_options
  ]
}

resource "aws_api_gateway_integration_response" "question_options_200" {
  rest_api_id = data.aws_api_gateway_rest_api.mysfit.id
  resource_id = aws_api_gateway_resource.question.id
  http_method = aws_api_gateway_method.question_options.http_method

  #--------------------------------------------------------------------------------
  # Create a dependency on the method response before creating integration response.
  #--------------------------------------------------------------------------------
  status_code = aws_api_gateway_method_response.question_options_200.status_code

  #--------------------------------------------------------------------------------
  # [REST API Reference - IntegrationResponse]
  # A key-value map specifying response parameters that are passed to the method response from the back end.
  # The key is a method response header parameter name and the mapped value is an integration response header value,
  # a static value enclosed within a pair of single quotes, or a JSON expression from the integration response body.
  # https://docs.aws.amazon.com/apigateway/api-reference/resource/integration-response/
  #--------------------------------------------------------------------------------
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,GET,PUT,POST,HEAD'"
    #--------------------------------------------------------------------------------
    # TODO: Need to limit to the project domain names
    #--------------------------------------------------------------------------------
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [
    aws_api_gateway_integration.question_options
  ]
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = data.aws_api_gateway_rest_api.mysfit.id
  stage_name  = var.ENV

  #--------------------------------------------------------------------------------
  # Force re-deployment
  # https://stackoverflow.com/questions/38910937/terraform-not-deploying-api-gateway-stage
  #--------------------------------------------------------------------------------
  variables = {
    deployed_at = timestamp()
  }

  depends_on = [
    #--------------------------------------------------------------------------------
    # To avoid race conditions, add an explicit depends_on = ["${aws_api_gateway_integration.name}"].
    # https://www.terraform.io/docs/providers/aws/r/api_gateway_deployment.html
    #--------------------------------------------------------------------------------
    aws_api_gateway_integration.question_post,
    aws_api_gateway_integration_response.question_options_200,
    #--------------------------------------------------------------------------------
    # To avoid "Execution failed due to configuration error: Invalid permissions on Lambda function"
    # Make sure to deploy the API stage after all the resoureces and permissions are ready.
    # - API resourece, methods, integrations, responses.
    # - IAM permissions (resourece based and identity based)
    #--------------------------------------------------------------------------------
    aws_lambda_permission.allow_apigw_invoke_lambda_receive_question_alias
  ]
}

locals {
  api_gateway_deployment_invoke_url = aws_api_gateway_deployment.this.invoke_url
}