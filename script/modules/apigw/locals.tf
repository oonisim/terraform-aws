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

#--------------------------------------------------------------------------------
# Indirection layer
# Instead of directly refer to the authorizer resource, access it via local
#--------------------------------------------------------------------------------

#--------------------------------------------------------------------------------
# API authorizer
#--------------------------------------------------------------------------------
locals {
  api_authorization_type = "${aws_api_gateway_authorizer.this.type}"
  api_authorizer_id = "${aws_api_gateway_authorizer.this.id}"
}

#--------------------------------------------------------------------------------
# API resource current version to use
#--------------------------------------------------------------------------------
locals {
  rest_api_id = "${aws_api_gateway_rest_api.this.id}"
  rest_api_current_resource_id = "${aws_api_gateway_resource.current.id}"
}

#--------------------------------------------------------------------------------
# API deployment
#--------------------------------------------------------------------------------
locals {
  api_deployment_invoke_url = "${aws_api_gateway_deployment.this.invoke_url}"
  #--------------------------------------------------------------------------------
  # NOTE:
  # Due to Workaround for #2918, ConflictException: Stage already exists,
  # the stage name of deployment is set to "".
  # https://github.com/terraform-providers/terraform-provider-aws/issues/2918
  #--------------------------------------------------------------------------------
  api_deployment_stage_name = "${aws_api_gateway_stage.this.stage_name}"
}

#--------------------------------------------------------------------------------
# Lambda function integration
#--------------------------------------------------------------------------------
locals {
  lambda_signin_invoke_arn      = "${data.aws_lambda_function.signin.invoke_arn}"
  lambda_signin_function_name   = "${data.aws_lambda_function.signin.function_name}"
  lambda_signin_qualifier        = "${data.aws_lambda_function.signin.qualifier}"
  lambda_create_invoke_arn      = "${data.aws_lambda_function.create.invoke_arn}"
  lambda_create_function_name   = "${data.aws_lambda_function.create.function_name}"
  lambda_create_qualifier        = "${data.aws_lambda_function.create.qualifier}"
  lambda_monitor_invoke_arn     = "${data.aws_lambda_function.monitor.invoke_arn}"
  lambda_monitor_function_name  = "${data.aws_lambda_function.monitor.function_name}"
  lambda_monitor_qualifier       = "${data.aws_lambda_function.monitor.qualifier}"
  lambda_delete_invoke_arn      = "${data.aws_lambda_function.delete.invoke_arn}"
  lambda_delete_function_name   = "${data.aws_lambda_function.delete.function_name}"
  lambda_delete_qualifier        = "${data.aws_lambda_function.delete.qualifier}"
}

