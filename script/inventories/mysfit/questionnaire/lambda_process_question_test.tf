#--------------------------------------------------------------------------------
# Test the process_question lambda function which handles an event from DyanamoDB stream event.
# The handler extracts question and email from each records in the event['Records'].
#
# for record in event['Records']:
#     item = record.get('dynamodb').get('NewImage')
#     questionText = item.get('QuestionText').get('S')
#     userEmail = item.get('UserEmailAddress').get('S')
#
# The event.json file contains a sample test DynamoDB Stream event.
# See https://docs.aws.amazon.com/lambda/latest/dg/with-ddb-example.html#with-dbb-invoke-manually
#
# To test the recieve_question lambda, the AWS resources need to be ready:
# - DynamoDB to get the questions posted
# - SNS to invoke publish from lambda
# - Lambda
#
# An error occurred (ServiceException) when calling the Invoke operation (reached max retries: 4):
# Lambda was unable to decrypt the environment variables due to an internal service error.
#--------------------------------------------------------------------------------
resource "null_resource" "test_lambda_process_question" {
  provisioner "local-exec" {
    working_dir = local.process_question_dir
    command     = <<EOF
rm -f outputfile.txt
echo "${local.lambda_process_question_iam_role_arn}"
echo "...waiting to avoid [Lambda was unable to decrypt the environment variables due to an internal service error]"
sleep 30

aws lambda invoke \
  --function-name ${local.lambda_process_question_qualified_arn} \
  --payload file://${local.process_question_dir}/event.json outputfile.txt

cat outputfile.txt
EOF
  }
  triggers = {
    #--------------------------------------------------------------------------------
    # Wait for the SNS, DynamoDB dependencies are ready.
    #--------------------------------------------------------------------------------
    sns_email_subscription                   = null_resource.sns_subscribe_to_email.id
    dynamodb_table_arn                       = aws_lambda_event_source_mapping.dynamodb_table_questionnaire.event_source_arn
    #--------------------------------------------------------------------------------
    # Trigger everytiem lambda is updated (published)
    #--------------------------------------------------------------------------------
    lambda_process_question_function_version = local.lambda_process_question_function_version
  }
}
