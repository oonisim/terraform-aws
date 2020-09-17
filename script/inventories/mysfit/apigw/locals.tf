locals {
  #----------------------------------------------------------------------
  # Normalize the path delimitar.
  # Terraform uses \ on Windows causing an error mixing them up with /.
  # "\terraform\modules\api/lambda/python.zip: The system cannot find the file specified"
  # https://github.com/hashicorp/terraform/issues/14986
  #----------------------------------------------------------------------

  #----------------------------------------------------------------------
  # No more required to handle backslash
  # https://github.com/hashicorp/terraform/issues/20064
  # We are also changing the path variables and path functions to always use forward slashes, even on Windows, for similar reasons.
  #module_path = replace(path.module, "\\", "/")
  #----------------------------------------------------------------------
  module_path = "${path.cwd}/${path.module}"
}

locals {
  vpc_ecs_cluster_id                    = "${data.terraform_remote_state.vpc.outputs.vpc_id}"
  vpc_ecs_cluster_cidr_block            = data.terraform_remote_state.vpc.outputs.vpc_cidr_block
  ecs_cluster_public_subnet_cidr_blocks = "${flatten([data.terraform_remote_state.vpc.outputs.public_subnets_cidr_blocks])}"
  ecs_cluster_public_subnet_ids         = "${flatten([data.terraform_remote_state.vpc.outputs.public_subnets])}"
}

#----------------------------------------------------------------------
# Authenticate API access
#----------------------------------------------------------------------
locals {
  cognito_userpool_id        = data.terraform_remote_state.cognito_idp.outputs.cognito_userpool_id
  cognito_userpool_client_id = data.terraform_remote_state.cognito_idp.outputs.cognito_userpool_client_id
}

#----------------------------------------------------------------------
# Forward mysfits API to the VPC private link of NLB front-end of Mysfits microservice.
#----------------------------------------------------------------------
locals {
  elb_dns_name = data.terraform_remote_state.lb.outputs.aws_lb_dns_name
  elb_arn      = data.terraform_remote_state.lb.outputs.aws_lb_arn
}
/*
#----------------------------------------------------------------------
# Firehose
#----------------------------------------------------------------------
locals {
  firehose_name = data.terraform_remote_state.kinesis_firehose.outputs.firehose_name
  firehose_arn  = data.terraform_remote_state.kinesis_firehose.outputs.firehose_arn
}

#----------------------------------------------------------------------
# Questionnaire
#----------------------------------------------------------------------
locals {
  lambda_receive_question_invoke_arn     = data.terraform_remote_state.questionnaire.outputs.lambda_receive_question_invoke_arn
  lambda_receive_question_function_name  = data.terraform_remote_state.questionnaire.outputs.lambda_receive_question_function_name
  lambda_receive_question_function_alias = data.terraform_remote_state.questionnaire.outputs.lambda_receive_question_function_alias
}
*/