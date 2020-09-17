#--------------------------------------------------------------------------------
# Test API
# [Question]
# Format:
# question = {
#   email: emailAddress,
#   questionText: questionToSubmit
# }
#
# [NOTE]
# Test MUST wait for all the pre-requisites to be ready:
# - Lambda function and alias
# - API Gateway resource, methods
# - IAM Permission for API Gateway to invoke Lambda
# - API Gateway deploymet (must be after all above)
#--------------------------------------------------------------------------------
resource "null_resource" "test_api_gateway_question_post_method" {
  provisioner "local-exec" {
    working_dir = local.module_path
    command     = <<EOF
curl -vL -XPOST \
  -d "@api_question.json" \
  "${aws_api_gateway_deployment.this.invoke_url}${aws_api_gateway_resource.question.path}"
EOF
  }
  triggers = {
    #--------------------------------------------------------------------------------
    # Wait for the DynamoDB dependencies is ready.
    # Wait for test_lambda_receive_question resource to finish
    # Wait for api gateway deployment to complete
    # Trigger everytiem lambda is updated (published)
    #--------------------------------------------------------------------------------
    #dynamodb_table_arn                       = local.dynamodb_table_questionnaire_arn
    #test_lambda_receive_question             = null_resource.test_lambda_receive_question.id
    #lambda_receive_question_function_version = local.lambda_receive_question_function_version
    aws_api_gateway_deployment               = aws_api_gateway_deployment.this.variables["deployed_at"]
  }
}
