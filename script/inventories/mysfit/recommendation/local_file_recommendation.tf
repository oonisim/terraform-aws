locals {
  recommendation_file_dir          = "${local.module_path}/${var.lambda_recommendation_dir}/${var.lambda_recommendation_alias_name}"
  recommendation_file_path         = "${local.recommendation_file_dir}/${var.lambda_recommendation_file_name}"
  recommendation_template_path     = "${local.recommendation_file_dir}/${var.lambda_recommendation_template_name}"
  recommendation_trigger_path      = "${local.recommendation_file_dir}/trigger"
  recommendation_requirements_path = "${local.recommendation_file_dir}/requirements.txt"
  recommendation_archive_path      = "${local.module_path}/${var.lambda_package_recommendation_dir}/${var.lambda_recommendation_alias_name}/${var.lambda_recommendation_archive_name}"
}

resource "local_file" "lambda_recommendation_py" {
  content  = templatefile(
  local.recommendation_template_path,
  {
    REPLACE_ME_SAGEMAKER_ENDPOINT_NAME = local.sagemaker_recommendation_endpoint_name
  }
  )
  filename = local.recommendation_file_path
}

locals {
  lambda_recommendation_dir = dirname(local_file.lambda_recommendation_py.filename)
}

resource "null_resource" "setup_lambda_recommendation_package" {
  provisioner "local-exec" {
    command     = <<EOF
      bash ./setup.sh
EOF
    working_dir = local.lambda_recommendation_dir
  }
  #--------------------------------------------------------------------------------
  # Lambda files needs to be readable by other for Lambda runtime account to run them.
  # The executable files needs to have x permission.
  #--------------------------------------------------------------------------------
  provisioner "local-exec" {
    command = <<EOF
      chmod    ugo+rx ${local.lambda_recommendation_dir}
      chmod -R ugo+r  ${local.lambda_recommendation_dir}/*
EOF

  }

  #       zip -vr "${local.recommendation_archive_path}" *  -x \"*.template\"
  provisioner "local-exec" {
    command     = <<EOF
      mkdir -p ${dirname(local.recommendation_archive_path)}
EOF
    working_dir = local.lambda_recommendation_dir
  }

  #--------------------------------------------------------------------------------
  # Regenerate lambda function package upon the change of the files.
  # Those trigger contents need to be changed before terraform apply to be able to trigger.
  #--------------------------------------------------------------------------------
  triggers = {
    template     = filemd5(local.recommendation_template_path)      # Lambda function
    requirements = filemd5(local.recommendation_requirements_path)  # Python requirements
    endpoint     = local.sagemaker_recommendation_endpoint_name     # SageMaker endpoint
    trigger      = filemd5(local.recommendation_trigger_path)       # Trigger file
  }

  depends_on = [
    local_file.lambda_recommendation_py
  ]
}

#--------------------------------------------------------------------------------
# To wait for null_resource
# https://github.com/hashicorp/terraform/issues/18303
#--------------------------------------------------------------------------------
resource "null_resource" "wait_for_lambda_package" {
  provisioner "local-exec" {
    command = <<EOF
ls -lrt "${local.recommendation_archive_path}"
EOF
  }
  triggers = {
    depends = null_resource.setup_lambda_recommendation_package.id
  }
}
data "archive_file" "lambda_package" {
  type        = "zip"
  source_dir  = local.lambda_recommendation_dir
  output_path = local.recommendation_archive_path

  depends_on = [
    null_resource.wait_for_lambda_package
  ]
}