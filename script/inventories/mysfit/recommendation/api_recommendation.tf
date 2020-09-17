/*--------------------------------------------------------------------------------
AWSTemplateFormatVersion: '2010-09-09'
Transform: AWS::Serverless-2016-10-31

Description: A stack that gives Mythical Mysfits the abillity to recommend
             Mysfits to a website user using machine learning.

Globals:
  Function:
    Runtime: python3.6
    MemorySize: 128
  Api:
    Cors:
      AllowMethods: "'*'"
      AllowHeaders: "'Content-Type,X-Amz-Date,Authorization,X-Api-Key'"
      AllowOrigin: "'*'"

Resources:
  MysfitsRecommendationsApi:
    Type: AWS::Serverless::Api
    Properties:
      StageName: prod

  # An IAM policy that permits Lambda funciton to invoke a SageMaker endpoint.
  MysfitsRecommendationFunctionPolicy:
    Type: 'AWS::IAM::ManagedPolicy'
    Properties:
      ManagedPolicyName: MythicalMysfitsRecommendationPolicy
      PolicyDocument:
        Version: 2012-10-17
        Statement:
          - Effect: Allow
            Action:
                - 'sagemaker:InvokeEndpoint'
            Resource: '*'

  MysfitsRecommendationFunction:
    DependsOn:
      - MysfitsRecommendationFunctionPolicy
    Type: 'AWS::Serverless::Function'
    Properties:
      Handler: recommendations.recommend
      CodeUri: ..
      Description: >-
        A microservice backend to invoke a SageMaker endpoint.
      Timeout: 30
      Policies:
        - !Ref MysfitsRecommendationFunctionPolicy
      Events:
        RecommendationsApi:
          Type: Api
          Properties:
            RestApiId: !Ref MysfitsRecommendationsApi
            Path: /recommendations
            Method: POST

Outputs:
  MysfitsRecommendationsApi:
    Description: The endpoint for the REST API created with API Gateway
    Value: !Join ['', ['https://', !Ref 'MysfitsRecommendationsApi',  '.execute-api.', !Ref 'AWS::Region', '.amazonaws.com/prod']]
--------------------------------------------------------------------------------*/
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
# API resource for Mysfit `recommendations`
#--------------------------------------------------------------------------------
resource "aws_api_gateway_resource" "recommendation" {
  rest_api_id = data.aws_api_gateway_rest_api.mysfit.id
  parent_id   = data.aws_api_gateway_rest_api.mysfit.root_resource_id
  path_part   = var.api_gateway_resource_recommendation_path
}

#--------------------------------------------------------------------------------
# Client is sending POST HTTP request with JSON body.
#
#$.ajax({
#  url : recommendationsApi,
#  type : 'POST',
#  headers : {'Content-Type': 'application/json'},
#  dataType: 'json',
#  data : JSON.stringify(questionnaireEntry),
#});
#--------------------------------------------------------------------------------
resource "aws_api_gateway_method" "recommendation_post" {
  rest_api_id   = data.aws_api_gateway_rest_api.mysfit.id
  resource_id   = aws_api_gateway_resource.recommendation.id
  http_method   = "POST"
  # TODO: Implment authorization
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "recommendation_post" {
  rest_api_id = data.aws_api_gateway_rest_api.mysfit.id
  resource_id = aws_api_gateway_resource.recommendation.id

  type                    = "AWS_PROXY"
  http_method             = aws_api_gateway_method.recommendation_post.http_method
  integration_http_method = "POST"
  uri                     = local.lambda_recommendation_invoke_arn
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
resource "aws_api_gateway_method" "recommendation_options" {
  rest_api_id   = data.aws_api_gateway_rest_api.mysfit.id
  resource_id   = aws_api_gateway_resource.recommendation.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "recommendation_options" {
  rest_api_id = data.aws_api_gateway_rest_api.mysfit.id
  resource_id = aws_api_gateway_resource.recommendation.id
  http_method = aws_api_gateway_method.recommendation_options.http_method
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
    aws_api_gateway_method.recommendation_options]
}

resource "aws_api_gateway_integration" "recommendation_options" {
  rest_api_id = data.aws_api_gateway_rest_api.mysfit.id
  resource_id = aws_api_gateway_resource.recommendation.id
  http_method = aws_api_gateway_method.recommendation_options.http_method
  type        = "MOCK"

  #--------------------------------------------------------------------------------
  # OPTIONS must reply {"statusCode": 200}
  # https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-mock-integration.html
  #--------------------------------------------------------------------------------
  request_templates = {
    "application/json" = "{'statusCode': 200}"
  }

  depends_on = [
    aws_api_gateway_method.recommendation_options
  ]
}

resource "aws_api_gateway_integration_response" "recommendation_options" {
  rest_api_id = data.aws_api_gateway_rest_api.mysfit.id
  resource_id = aws_api_gateway_resource.recommendation.id
  http_method = aws_api_gateway_method.recommendation_options.http_method
  status_code = aws_api_gateway_method_response.recommendation_options.status_code

  #--------------------------------------------------------------------------------
  # [REST API Reference - IntegrationResponse]
  # A key-value map specifying response parameters that are passed to the method response from the back end.
  # The key is a method response header parameter name and the mapped value is an integration response header value,
  # a static value enclosed within a pair of single quotes, or a JSON expression from the integration response body.
  # https://docs.aws.amazon.com/apigateway/api-reference/resource/integration-response/
  #--------------------------------------------------------------------------------
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,PUT'"
    #--------------------------------------------------------------------------------
    # TODO: Need to limit to the project domain names
    #--------------------------------------------------------------------------------
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on          = [
    aws_api_gateway_integration.recommendation_options
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
    aws_api_gateway_integration.recommendation_post,
    aws_api_gateway_integration_response.recommendation_options,
    #--------------------------------------------------------------------------------
    # To avoid "Execution failed due to configuration error: Invalid permissions on Lambda function"
    # Make sure to deploy the API stage after all the resoureces and permissions are ready.
    # - API resourece, methods, integrations, responses.
    # - IAM permissions (resourece based and identity based)
    #--------------------------------------------------------------------------------
    aws_lambda_permission.allow_apigw_invoke_lambda_recommendation_alias
  ]
}

locals {
  api_gateway_deployment_invoke_url = aws_api_gateway_deployment.this.invoke_url
}