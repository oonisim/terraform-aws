#--------------------------------------------------------------------------------
# API Deployment
#--------------------------------------------------------------------------------
# [Deployment Stage]
# The stage equals with the environment of the project (e.g. dev/uat/prd).
#
# [Notes on Terraform]
# Run deployment one by one to avoid "another deployment in progress".
# -> Create dependency chanin from one deployment to another.
#--------------------------------------------------------------------------------
resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  #--------------------------------------------------------------------------------
  # Workaround for #2918 ConflictException: Stage already exists
  # https://github.com/terraform-providers/terraform-provider-aws/issues/2918
  #
  # NOTE:
  # The invoke_url will miss stage name!
  #--------------------------------------------------------------------------------
  #stage_name  = "${var.ENV}"
  stage_name = ""
  #--------------------------------------------------------------------------------

  #--------------------------------------------------------------------------------
  # Force re-deployment at each run. Alternative is to verify MD5 of API GW files.
  #--------------------------------------------------------------------------------
  # https://medium.com/coryodaniel/til-forcing-terraform-to-deploy-a-aws-api-gateway-deployment-ed36a9f60c1a
  # https://github.com/hashicorp/terraform/issues/6613
  # Terraform’s aws_api_gateway_deployment won’t deploy subsequent releases in the event
  # that something has changed in an integration, method, etc
  #--------------------------------------------------------------------------------
  /* Alternative way
  variables = {
    deployed_at = timestamp()
  }
  */
  stage_description = "Deployment at ${timestamp()}"
  /*
  stage_description = "${md5(
    format("%s%s",
      file("${path.module}/geophys.tf"),
      file("${path.module}/apigw_authorizer_cognito.tf")
    )
  )}"
  */

  #--------------------------------------------------------------------------------
  # [aws_api_gateway_account.this]
  # To avoid the error: Updating API Gateway Stage failed:
  # BadRequestException: CloudWatch Logs role ARN must be set in account settings to enable logging.
  #--------------------------------------------------------------------------------
  depends_on = [
    aws_api_gateway_account.this,
    aws_api_gateway_integration.authping_get,
    aws_api_gateway_integration.ping_options,
    aws_api_gateway_integration.authping_options,
    aws_api_gateway_integration.signin_get,
    aws_api_gateway_integration.signin_options,
    aws_api_gateway_integration.job_get,
    aws_api_gateway_integration.job_post,
    aws_api_gateway_integration.jobid_get,
    aws_api_gateway_integration.jobid_options,
    aws_api_gateway_integration.jobid_delete,
  ]

  #--------------------------------------------------------------------------------

  #--------------------------------------------------------------------------------
  # To avoid BadRequestException: Active stages pointing to this deployment must be moved or deleted
  # https://github.com/hashicorp/terraform/issues/10674
  #--------------------------------------------------------------------------------
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "this" {
  #--------------------------------------------------------------------------------
  # Workaround for #2918 ConflictException: Stage already exists
  # https://github.com/terraform-providers/terraform-provider-aws/issues/2918
  #stage_name    = "${aws_api_gateway_deployment.this.stage_name}"
  stage_name = var.ENV

  #--------------------------------------------------------------------------------
  rest_api_id   = aws_api_gateway_rest_api.this.id
  deployment_id = aws_api_gateway_deployment.this.id

  #access_log_settings {
  #  destination_arn = "${aws_cloudwatch_log_group.access_log.arn}"
  #  format = "${file("${path.module}/apigw/apigw_access_log_format.json")}"
  #}

  xray_tracing_enabled = var.xray_tracing_enabled

  lifecycle {
    create_before_destroy = true
  }
}

