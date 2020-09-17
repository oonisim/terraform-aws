resource "aws_lambda_event_source_mapping" "dynamodb_table_questionnaire" {
  event_source_arn  = module.dynamodb_table_questionnaire.stream_arn
  function_name     = module.lambda_process_question.lambda_function_qualified_arn
  starting_position = "LATEST"
}