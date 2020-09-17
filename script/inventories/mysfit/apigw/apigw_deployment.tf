resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.mysfit.id
  #--------------------------------------------------------------------------------
  # Workaround for #2918 ConflictException: Stage already exists
  # https://github.com/terraform-providers/terraform-provider-aws/issues/2918
  #
  # !!!WAARNING!!!
  # The invoke_url will miss stage name!!!
  #
  #--------------------------------------------------------------------------------
  # Causes"Error creating API Gateway Stage: ConflictException: Stage already exists"
  #stage_name  = "${var.ENV}"
  #--------------------------------------------------------------------------------

  #--------------------------------------------------------------------------------
  # Force re-deployment
  # https://stackoverflow.com/questions/38910937/terraform-not-deploying-api-gateway-stage
  #
  # See https://github.com/hashicorp/terraform/issues/6613 for the comment by M.Atkins
  # The inability for Terraform to understand implicit update relationships between
  # resources is known,and so far we've tended to solve it in more targeted ways by
  # adding special "change detector" attributes to resources, such as the source_code_hash
  # on aws_lambda_function, the etag on aws_s3_bucket_object, and the keepers on
  # the resources in the random provider.
  #
  # https://github.com/terraform-providers/terraform-provider-aws/issues/162 has a
  # workaround to take SHA of the concatenated resource JSON representation.
  # resource "aws_api_gateway_deployment" "demo" {
  #   rest_api_id = aws_api_gateway_rest_api.demo.id
  #
  #   variables = {
  #     trigger_hash = sha1(join(",", [
  #       jsonencode(aws_api_gateway_resource.demo),
  #       jsonencode(aws_api_gateway_method.demo_get),
  #       // Etc. ...
  #       //
  #     ]))
  #   }
  #   lifecycle {
  #     create_before_destroy = true
  #   }
  # }
  #--------------------------------------------------------------------------------
  variables = {
    deployed_at = timestamp()
  }

  depends_on = [
    #--------------------------------------------------------------------------------
    # To avoid race conditions, add an explicit depends_on = ["${aws_api_gateway_integration.name}"].
    # https://www.terraform.io/docs/providers/aws/r/api_gateway_deployment.html
    #--------------------------------------------------------------------------------
    aws_api_gateway_rest_api.mysfit,
    aws_api_gateway_account.this,

    #--------------------------------------------------------------------------------
    # Userevent
    #--------------------------------------------------------------------------------
    #aws_api_gateway_integration.click_put,
    #aws_api_gateway_integration_response.click_put,
    #aws_api_gateway_integration_response.click_options,

    #--------------------------------------------------------------------------------
    # Question
    #--------------------------------------------------------------------------------
    #aws_api_gateway_integration.question_post,
    #aws_api_gateway_integration_response.question_options_200,
    #--------------------------------------------------------------------------------
    # To avoid "Execution failed due to configuration error: Invalid permissions on Lambda function"
    # Make sure to deploy the API stage after all the resoureces and permissions are ready.
    # - API resourece, methods, integrations, responses.
    # - IAM permissions (resourece based and identity based)
    #--------------------------------------------------------------------------------
    #aws_lambda_permission.allow_apigw_invoke_lambda_receive_question_alias

    #--------------------------------------------------------------------------------
    # Recommendation
    #--------------------------------------------------------------------------------
    #aws_api_gateway_integration.recommendation_post,
    #aws_api_gateway_integration_response.recommendation_options,

  ]

  #--------------------------------------------------------------------------------
  # "BadRequestException: Active stages pointing to this deployment must be moved or deleted"
  # https://github.com/hashicorp/terraform/issues/10674
  # https://github.com/terraform-providers/terraform-provider-aws/issues/10105
  #--------------------------------------------------------------------------------
  lifecycle {
    create_before_destroy = true
  }
}

module "cloudwatch" {
  source = "../../../modules/cloudwatch"

  PROJECT = var.PROJECT
  ENV     = var.ENV

  loggroup_name = var.enable_apigw_stage_cloudwatch_access_log != null ? var.apigw_stage_cloudwatch_access_loggroup_name : null
}

resource "aws_api_gateway_stage" "this" {
  stage_name    = var.ENV
  rest_api_id   = aws_api_gateway_rest_api.mysfit.id
  deployment_id = aws_api_gateway_deployment.this.id

  dynamic "access_log_settings" {
    for_each = var.enable_apigw_stage_cloudwatch_access_log ? [1] : []
    content {
      destination_arn = module.cloudwatch.cloudwatch_loggroup_arn
      format          = file("${path.module}/apigw_access_log_format.json")
    }
  }

  xray_tracing_enabled = var.xray_tracing_enabled

  tags = {
    Project     = var.PROJECT
    Environment = var.ENV
  }
}


#--------------------------------------------------------------------------------
# Force re-deploy as the first deployment has no stage_name and having it will
# cause the "ConflictException: Stage already exist".
#--------------------------------------------------------------------------------
resource "aws_api_gateway_deployment" "second" {
  rest_api_id = aws_api_gateway_rest_api.mysfit.id
  stage_name  = var.ENV

  variables = {
    deployed_at = timestamp()
  }
  depends_on = [
    aws_api_gateway_stage.this
  ]
  lifecycle {
    create_before_destroy = true
  }
}

# Expose I/F
locals {
  #api_gateway_deployment_stage_name = aws_api_gateway_deployment.this.stage_name
  #--------------------------------------------------------------------------------
  # Due to the workaround of #2918 ConflictException: Stage already exists,
  # the deployment does not have "stage". Hence append the stage name
  # https://github.com/terraform-providers/terraform-provider-aws/issues/2918
  # !!!WAARNING!!!
  # The invoke_url will miss stage name!!!
  #--------------------------------------------------------------------------------
  #api_gateway_deployment_invoke_url = aws_api_gateway_deployment.this.stage_name == null ? "${aws_api_gateway_deployment.this.invoke_url}${aws_api_gateway_stage.this.stage_name}" : aws_api_gateway_deployment.this.invoke_url
  api_gateway_deployment_invoke_url = aws_api_gateway_deployment.second.invoke_url
  api_gateway_deployment_stage_name = aws_api_gateway_deployment.second.stage_name
}