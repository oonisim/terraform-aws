# The lambda expects the input format below.
# "records": [
# {
#   "recordId": ...,
#   "data" : ...
# }
# ...
# ]

resource "null_resource" "test_lambda_transform" {
  provisioner "local-exec" {
    command     = <<EOF
sleep 10

aws lambda invoke --function-name ${module.lambda.lambda_function_name} \
--qualifier ${module.lambda.lambda_function_alias} \
--payload file://${local.module_path}/lambda/tests/transform/event.json \
response.json && cat response.json
EOF
    working_dir = local.lambda_transform_dir
  }

  triggers = {
    # To wait for the build as null_resource does not wait for local-exec completion.
    # Use null_resouce id which is generated everytime for null_resouce.
    # https://github.com/hashicorp/terraform/issues/18303
    # Providers need to be configured even for the plan phase, and therefore they can't
    # depend on anything that hasn't been created yet at that phase.
    build = null_resource.build_lambda_transform_package.id

    # Run test everytime version is updated.
    version = module.lambda.lambda_function_version
  }

  depends_on = [
    null_resource.build_lambda_transform_package,
    data.archive_file.lambda_package
  ]
}