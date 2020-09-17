#--------------------------------------------------------------------------------
# API resource (an object representing feature/function of a business, e.g. HR payroll)
#--------------------------------------------------------------------------------
resource "aws_api_gateway_resource" "lambda_kinesis_producer" {
  rest_api_id   = "${data.aws_api_gateway_rest_api.that.id}"
  parent_id     = "${data.aws_api_gateway_rest_api.that.root_resource_id}"
  path_part     = "push"
}
# Method represents an interface of the object (resource)
resource "aws_api_gateway_method" "lambda_kinesis_producer_post" {
  rest_api_id   = "${data.aws_api_gateway_rest_api.that.id}"
  resource_id   = "${aws_api_gateway_resource.lambda_kinesis_producer.id}"
  http_method   = "POST"
  authorization = "NONE"
/*
  authorization = "${var.api_gateway_authorization}"
  authorizer_id = "${var.api_gateway_authorizer_id}"
*/
}
resource "aws_api_gateway_integration" "lambda_kinesis_producer_post" {
  rest_api_id   = "${data.aws_api_gateway_rest_api.that.id}"
  resource_id   = "${aws_api_gateway_method.lambda_kinesis_producer_post.resource_id}"
  http_method   = "${aws_api_gateway_method.lambda_kinesis_producer_post.http_method}"

  #--------------------------------------------------------------------------------
  # Lambda Proxy integration (AWS_PROXY) integration method MUST be POST.
  # https://stackoverflow.com/questions/41371970
  #--------------------------------------------------------------------------------
  #integration_http_method = "GET"
  integration_http_method = "POST"
  #--------------------------------------------------------------------------------
  type                    = "AWS_PROXY"  # Lambda Proxy
  uri                     = "${local.lambda_kinesis_producer_invoke_arn}"
}
