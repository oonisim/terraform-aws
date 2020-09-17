#--------------------------------------------------------------------------------
# Lambda to process questions
#--------------------------------------------------------------------------------
lambda_process_question_dir            = "lambda/ProcessQuestionsStream"
lambda_process_question_template_name  = "mysfitsProcessStream.py.template"
lambda_process_question_archive_name   = "mysfitsProcessStream.zip"
lambda_process_question_package_dir    = "lambda/packages/ProcessQuestionsStream"
lambda_process_question_function_name  = "mysfitsProcessStream"
lambda_process_question_alias_name     = "v1"
lambda_process_question_file_name      = "mysfitsProcessStream.py"
lambda_process_question_handler_method = "processStream"
lambda_process_question_runtime        = "python3.8"
lambda_process_question_memory_size    = 300
lambda_process_question_timeout        = 900
