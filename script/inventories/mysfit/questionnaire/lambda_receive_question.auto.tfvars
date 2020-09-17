#--------------------------------------------------------------------------------
# Lambda to handle questions to save to the database
#--------------------------------------------------------------------------------
lambda_receive_question_dir            = "lambda/ReceiveQuestionsService"
lambda_receive_question_template_name  = "mysfitsReceiveQuestion.py.template"
lambda_receive_question_archive_name   = "mysfitsReceiveQuestion.zip"
lambda_receive_question_package_dir    = "lambda/packages/ReceiveQuestionsService"
lambda_receive_question_function_name  = "mysfitsReceiveQuestion"
lambda_receive_question_alias_name     = "v1"
lambda_receive_question_file_name      = "mysfitsReceiveQuestion.py"
lambda_receive_question_handler_method = "recieveQuestion"
lambda_receive_question_runtime        = "python3.8"
lambda_receive_question_memory_size    = 300
lambda_receive_question_timeout        = 900
