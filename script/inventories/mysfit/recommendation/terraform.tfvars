#--------------------------------------------------------------------------------
# Lambda to get recommendations from SageMaker endpoint
#--------------------------------------------------------------------------------
lambda_recommendation_dir            = "lambda/recommendation"
lambda_recommendation_template_name  = "recommendation.py.template"
lambda_recommendation_archive_name   = "recommendation.zip"
lambda_package_recommendation_dir    = "lambda/packages/recommendation"
lambda_recommendation_function_name  = "recommendation"
lambda_recommendation_alias_name     = "v1"
lambda_recommendation_file_name      = "recommendation.py"
lambda_recommendation_handler_method = "recommend"
lambda_recommendation_runtime        = "python3.8"
lambda_recommendation_memory_size    = 300
lambda_recommendation_timeout        = 900

