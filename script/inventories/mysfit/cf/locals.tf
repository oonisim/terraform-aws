#----------------------------------------------------------------------
# Common
#----------------------------------------------------------------------
/*
locals {
  cognito_userpool_id             = data.terraform_remote_state.cognito_idp.outputs.cognito_userpool_id
  cognito_userpool_client_id      = data.terraform_remote_state.cognito_idp.outputs.cognito_userpool_client_id
  apigw_mysfit_invoke_url         = data.terraform_remote_state.apigw.outputs.api_gateway_deployment_invoke_url
  apigw_userevent_invoke_url      = data.terraform_remote_state.apigw.outputs.api_gateway_deployment_invoke_url
  apigw_questionnaire_invoke_url  = data.terraform_remote_state.apigw.outputs.api_gateway_deployment_invoke_url
  apigw_recommendation_invoke_url = data.terraform_remote_state.apigw.outputs.api_gateway_deployment_invoke_url
}
*/
locals {
  cognito_userpool_id            = data.terraform_remote_state.cognito_idp.outputs.cognito_userpool_id
  cognito_userpool_client_id     = data.terraform_remote_state.cognito_idp.outputs.cognito_userpool_client_id
  apigw_stage_name               = data.terraform_remote_state.apigw.outputs.api_gateway_deployment_stage_name
  apigw_mysfit_invoke_url        = data.terraform_remote_state.apigw.outputs.api_gateway_deployment_invoke_url
  apigw_userevent_invoke_url     = data.terraform_remote_state.userevent.outputs.api_gateway_deployment_invoke_url
  apigw_questionnaire_invoke_url = data.terraform_remote_state.questionnaire.outputs.api_gateway_deployment_invoke_url
  #  apigw_recommendation_invoke_url = data.terraform_remote_state.recommendation.outputs.api_gateway_deployment_invoke_url
}