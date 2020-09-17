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
  lambda_transform_function_name  = data.terraform_remote_state.lambda.outputs.lambda_function_name
  lambda_transform_function_alias = data.terraform_remote_state.lambda.outputs.lambda_function_alias
  lambda_function_invoke_arn      = data.terraform_remote_state.lambda.outputs.lambda_function_invoke_arn

  # Bucket to upload lambda package
  bucket_name = data.terraform_remote_state.s3.outputs.bucket_data
  api_gateway_rest_api_id                = data.terraform_remote_state.apigw.outputs.api_gateway_rest_api_id
  api_gateway_rest_api_name              = data.terraform_remote_state.apigw.outputs.api_gateway_rest_api_name
}