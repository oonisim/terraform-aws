#--------------------------------------------------------------------------------
# DynamoDB table to store questions posted.
#--------------------------------------------------------------------------------
module "dynamodb_table_questionnaire" {
  source = "../../../modules/dynamodb"

  PROJECT = var.PROJECT
  ENV     = var.ENV
  REGION  = var.REGION

  #--------------------------------------------------------------------------------
  # The DynamoDB table fields must match with those used in the Lambda function.
  #--------------------------------------------------------------------------------
  name     = var.dynamodb_table_name
  hash_key = var.dynamodb_table_hash_key

  autoscale_min_read_capacity  = 5
  autoscale_min_write_capacity = 5

  #--------------------------------------------------------------------------------
  # Stream
  #--------------------------------------------------------------------------------
  enable_streams   = var.dynamodb_table_enable_streams
  stream_view_type = var.dynamodb_table_stream_view_type
}

# Expose I/F
locals {
  dynamodb_table_questionnaire_arn       = module.dynamodb_table_questionnaire.arn
  dynamodb_table_questionnaire_name      = module.dynamodb_table_questionnaire.name
  dynamodb_table_questionnaire_region    = module.dynamodb_table_questionnaire.region
  dynamodb_table_questionnaire_hash_key  = module.dynamodb_table_questionnaire.hash_key
  dynamodb_table_questionnaire_range_key = module.dynamodb_table_questionnaire.range_key
}