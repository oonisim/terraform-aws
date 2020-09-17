#--------------------------------------------------------------------------------
# DynamoDB
#--------------------------------------------------------------------------------
dynamodb_table_name = "MysfitsQuestionsTable"
dynamodb_table_hash_key = "QuestionId"
dynamodb_table_global_secondary_index_map = []
dynamodb_table_enable_streams = true
dynamodb_table_stream_view_type = "NEW_IMAGE"
