#--------------------------------------------------------------------------------
# Test Lambda
# Without sleep and wait, an error:
#
# An error occurred (ServiceException) when calling the Invoke operation (reached max retries: 4):
# Lambda was unable to decrypt the environment variables due to an internal service error.
#--------------------------------------------------------------------------------
resource "null_resource" "test_lambda_receive_question" {
  provisioner "local-exec" {
    working_dir = local.receive_question_dir
    command     = <<EOF
rm -f outputfile.txt
echo "${local.lambda_receive_question_iam_role_arn}"
echo "...waiting to avoid [Lambda was unable to decrypt the environment variables due to an internal service error]"
sleep 30

aws lambda invoke \
  --function-name ${local.lambda_receive_question_qualified_arn} \
  --payload file://${local.receive_question_dir}/event.json outputfile.txt

cat outputfile.txt
EOF
  }
  triggers = {
    #--------------------------------------------------------------------------------
    # Wait for the DynamoDB dependencies is ready.
    # Trigger everytiem lambda is updated (published)
    #--------------------------------------------------------------------------------
    dynamodb_table_arn                       = local.dynamodb_table_questionnaire_arn
    lambda_receive_question_function_version = local.lambda_receive_question_function_version
  }
}
