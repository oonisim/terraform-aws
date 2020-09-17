/*--------------------------------------------------------------------------------
"/clicks":
  put:
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
            method.response.header.Access-Control-Allow-Methods: "'OPTIONS, PUT'"
            method.response.header.Access-Control-Allow-Origin: "'*'"
      credentials: !GetAtt ClickProcessingApiRole.Arn
      connectionType: INTERNET
      httpMethod: POST
      type: AWS
      uri: !Join ["", ["arn:aws:apigateway:", { "Ref": "AWS::Region" }, ":firehose:action/PutRecord" ] ]
      # The below requestTemplate transforms the incoming JSON
      # payload into the request object structure that the Kinesis
      # Firehose PutRecord API requires. So now our frontend
      # JavaScript can call an API that we have designed ourselves
      # while actually directly integrating with an AWS Service API.
      requestTemplates:
        application/json: !Join ["", ["{ \"DeliveryStreamName\": \"", !Ref MysfitsFireHoseToS3, "\",    \"Record\": {   \"Data\": \"$util.base64Encode($input.json('$'))\" } }" ] ]
      requestParameters:
        integration.request.header.Content-Type: "'application/x-amz-json-1.1'"
--------------------------------------------------------------------------------*/

#--------------------------------------------------------------------------------
# Get the mysfit rest API and root resource
#--------------------------------------------------------------------------------
data "aws_api_gateway_rest_api" "mysfit" {
  name = local.api_gateway_rest_api_name
}

#--------------------------------------------------------------------------------
# API resource for User `Clicks`
#--------------------------------------------------------------------------------
resource "aws_api_gateway_resource" "click" {
  rest_api_id = data.aws_api_gateway_rest_api.mysfit.id
  parent_id   = data.aws_api_gateway_rest_api.mysfit.root_resource_id
  path_part   = var.api_gateway_resource_click_path
}

resource "aws_api_gateway_method" "click_put" {
  rest_api_id   = data.aws_api_gateway_rest_api.mysfit.id
  resource_id   = aws_api_gateway_resource.click.id
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "click_put" {
  rest_api_id = data.aws_api_gateway_rest_api.mysfit.id
  resource_id = aws_api_gateway_resource.click.id

  #--------------------------------------------------------------------------------
  # Integration type "AWS" to call Firehose PutRecord API
  # [URI]
  # For AWS integrations, the URI form is "arn:aws:apigateway:{region}:{subdomain.service|service}:{path|action}/{service_api}".
  # region, subdomain and service are used to determine the right endpoint.
  # e.g. arn:aws:apigateway:eu-west-1:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-west-1:012345678901:function:my-func/invocations
  #
  # [Credential]
  # Permission to call the target AWS service. Specify IAM Role to for API Gateway to assume,
  # or specify "arn:aws:iam::\*:user/\* for the caller's identity to be passed through from the request,
  #--------------------------------------------------------------------------------
  type        = "AWS"
  uri         = "arn:aws:apigateway:${var.REGION}:firehose:action/PutRecord"
  credentials = aws_iam_role.api_click.arn

  #--------------------------------------------------------------------------------
  # https://github.com/hashicorp/terraform/issues/10501
  # http_method is the method to use when calling the API Gateway endpoint (from the client)
  # integration_http_method is the method used by API Gateway to call the backend
  #--------------------------------------------------------------------------------
  # http_method is mandatory attribute
  #http_method = aws_api_gateway_method.click_put.http_method
  http_method = aws_api_gateway_method.click_put.http_method
  #--------------------------------------------------------------------------------

  #--------------------------------------------------------------------------------
  # integration_http_method is required if type is AWS, AWS_PROXY, HTTP or HTTP_PROXY
  # Firehose PutRecord API I/F is POST
  # POST / HTTP/1.1
  # Host: firehose.<region>.<domain>
  # https://docs.aws.amazon.com/firehose/latest/APIReference/API_PutRecord.html#API_PutRecord_Examples
  #--------------------------------------------------------------------------------
  #integration_http_method = aws_api_gateway_method.click_put.http_method
  integration_http_method = "POST"
  #--------------------------------------------------------------------------------

  #--------------------------------------------------------------------------------
  # A map of request query parameters and headers that should be passed to the integration backend.
  #--------------------------------------------------------------------------------
  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-amz-json-1.1'"
  }

  #--------------------------------------------------------------------------------
  #(Optional) Passthrough behavior (WHEN_NO_MATCH, WHEN_NO_TEMPLATES, NEVER).
  # Required if request_templates is used.
  #--------------------------------------------------------------------------------
  # Must use mapping to adapt the HTTP?PUT request body to Firehose PutRecord API.
  passthrough_behavior = "NEVER"

  #--------------------------------------------------------------------------------
  # Requst mapping template to map HTTP/PUT JSON body to Firehose PutRecord API arguments
  #--------------------------------------------------------------------------------
  request_templates = {
    #--------------------------------------------------------------------------------
    # API Gateway data transformation (Velocity template + JSON Path)
    # https://docs.aws.amazon.com/apigateway/latest/developerguide/rest-api-data-transformations.html
    #
    # Mapping user click event JSON to Firehose PutRecod request JSON
    # userClick = {
    #   userId: currentUserId,
    #   mysfitId: clickedMysfitId
    # }
    #
    # Firehose PutRecod
    # https://docs.aws.amazon.com/firehose/latest/APIReference/API_PutRecord.html
    # {
    #   "DeliveryStreamName": "string",
    #   "Record": {
    #     "Data": blob
    #   }
    # }
    #--------------------------------------------------------------------------------
    "application/json" = <<EOF
{
  "DeliveryStreamName": "${local.firehose_name}",
  "Record": {
    "Data": "$util.base64Encode($input.json('$'))"
  }
}
EOF
  }
}

resource "aws_api_gateway_method_response" "click_put" {
  rest_api_id = data.aws_api_gateway_rest_api.mysfit.id
  resource_id = aws_api_gateway_resource.click.id
  http_method = aws_api_gateway_method.click_put.http_method
  status_code = "200"

  #--------------------------------------------------------------------------------
  # [Model for method response]
  # Model resources used for the response's content-type.
  # Response models are key/value maps; ontent-type as the key and a Model name as value.
  # https://docs.aws.amazon.com/apigateway/api-reference/resource/method-response/
  #--------------------------------------------------------------------------------
  response_models = {
    #--------------------------------------------------------------------------------
    # Place the dependency on the model to avoid "Cannot delete model 'Empty', is referenced in method response"
    #--------------------------------------------------------------------------------
    "application/json" = "Empty"
    #"application/json" = aws_api_gateway_model.empty.name
    #--------------------------------------------------------------------------------
  }

  #--------------------------------------------------------------------------------
  # API Reference - MethodResponse
  # A key-value map specifying required or optional response parameters that API Gateway **CAN** send back to the caller.
  # -> boolean
  # https://docs.aws.amazon.com/apigateway/api-reference/resource/method-response/
  #--------------------------------------------------------------------------------
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "click_put" {
  rest_api_id = data.aws_api_gateway_rest_api.mysfit.id
  resource_id = aws_api_gateway_resource.click.id
  http_method = aws_api_gateway_method.click_put.http_method
  status_code = aws_api_gateway_method_response.click_put.status_code

  #--------------------------------------------------------------------------------
  # [REST API Reference - IntegrationResponse]
  # A key-value map specifying response parameters that are passed to the method response from the back end.
  # The key is a method response header parameter name and the mapped value is an integration response header value,
  # a static value enclosed within a pair of single quotes, or a JSON expression from the integration response body.
  # https://docs.aws.amazon.com/apigateway/api-reference/resource/integration-response/
  #--------------------------------------------------------------------------------
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  #--------------------------------------------------------------------------------
  # To avoid "Error creating API Gateway Integration Response:
  # NotFoundException: Invalid Integration identifier specified".
  #
  # It looks API Integration with another AWS Service may take time to complete?
  #
  # Terraform document of API Gateway deployment also suggests there is a race condition
  # about integration and recommends to put the dependency on it.
  # To avoid race conditions, add an explicit depends_on = ["${aws_api_gateway_integration.name}"].
  # https://www.terraform.io/docs/providers/aws/r/api_gateway_deployment.html
  #
  # API gateway integration issue - Invalid Method identifier specified Error #4001
  # also put a sleep wait, although it is on an API Resource.
  # https://github.com/terraform-providers/terraform-provider-aws/issues/4001
  #--------------------------------------------------------------------------------
  depends_on = [
    aws_api_gateway_integration.click_put
  ]
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
resource "aws_api_gateway_method" "click_options" {
  rest_api_id   = data.aws_api_gateway_rest_api.mysfit.id
  resource_id   = aws_api_gateway_resource.click.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "click_options" {
  rest_api_id = data.aws_api_gateway_rest_api.mysfit.id
  resource_id = aws_api_gateway_resource.click.id
  http_method = aws_api_gateway_method.click_options.http_method
  status_code = "200"

  #--------------------------------------------------------------------------------
  # [Model for method response]
  # Model resources used for the response's content-type.
  # Response models are key/value maps; ontent-type as the key and a Model name as value.
  # https://docs.aws.amazon.com/apigateway/api-reference/resource/method-response/
  #--------------------------------------------------------------------------------
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
  depends_on = [aws_api_gateway_method.click_options]
}

resource "aws_api_gateway_integration" "click_options" {
  rest_api_id = data.aws_api_gateway_rest_api.mysfit.id
  resource_id = aws_api_gateway_resource.click.id
  http_method = aws_api_gateway_method.click_options.http_method
  type        = "MOCK"

  #--------------------------------------------------------------------------------
  # OPTIONS must reply {"statusCode": 200}
  # https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-mock-integration.html
  #--------------------------------------------------------------------------------
  request_templates = {
    "application/json" = "{'statusCode': 200}"
  }

  depends_on  = [aws_api_gateway_method.click_options]
}

resource "aws_api_gateway_integration_response" "click_options" {
  rest_api_id = data.aws_api_gateway_rest_api.mysfit.id
  resource_id = aws_api_gateway_resource.click.id
  http_method = aws_api_gateway_method.click_options.http_method
  status_code = aws_api_gateway_method_response.click_options.status_code

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
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  depends_on = [aws_api_gateway_method_response.click_options]
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
    aws_api_gateway_integration.click_put,
    aws_api_gateway_integration_response.click_put,
    aws_api_gateway_integration_response.click_options
  ]
}

locals {
  api_gateway_deployment_invoke_url = aws_api_gateway_deployment.this.invoke_url
}