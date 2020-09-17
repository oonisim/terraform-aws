locals {
  transform_file_dir          = "${local.module_path}/${var.lambda_transform_dir}/${var.lambda_transform_alias_name}"
  transform_file_path         = "${local.transform_file_dir}/${var.lambda_transform_file_name}"
  transform_template_path     = "${local.transform_file_dir}/${var.lambda_transform_template_name}"
  transform_trigger_path      = "${local.transform_file_dir}/trigger"
  transform_requirements_path = "${local.transform_file_dir}/requirements.txt"
  transform_archive_path      = "${local.module_path}/${var.lambda_package_transform_dir}/${var.lambda_transform_alias_name}/${var.lambda_transform_archive_name}"
}

resource "local_file" "lambda_transform_py" {
  content  = templatefile(
  local.transform_template_path,
  {
    REPLACE_ME_API_MYSFIT_ENDPOINT = local.apigw_mysfit_invoke_url
  }
  )
  filename = local.transform_file_path
}

locals {
  lambda_transform_dir = dirname(local_file.lambda_transform_py.filename)
}

resource "null_resource" "build_lambda_transform_package" {
  provisioner "local-exec" {
    command     = <<EOF
      bash ./setup.sh
EOF
    working_dir = local.lambda_transform_dir
  }
  #--------------------------------------------------------------------------------
  # Lambda files needs to be readable by other for Lambda runtime account to run them.
  # The executable files needs to have x permission.
  #--------------------------------------------------------------------------------
  provisioner "local-exec" {
    command = <<EOF
      chmod    ugo+rx ${local.lambda_transform_dir}
      chmod -R ugo+r  ${local.lambda_transform_dir}/*
EOF

  }

  #       zip -vr "${local.transform_archive_path}" *  -x \"*.template\"
  provisioner "local-exec" {
    command     = <<EOF
      mkdir -p ${dirname(local.transform_archive_path)}
EOF
    working_dir = local.lambda_transform_dir
  }

  #--------------------------------------------------------------------------------
  # Regenerate lambda function package upon the change of the files.
  # Those trigger contents need to be changed before terraform apply to be able to trigger.
  #--------------------------------------------------------------------------------
  triggers = {
    template     = filemd5(local.transform_template_path)
    requirements = filemd5(local.transform_requirements_path)
    endpoint     = local.apigw_mysfit_invoke_url
    trigger      = filemd5(local.transform_trigger_path)
  }

  depends_on = [
    local_file.lambda_transform_py
  ]
}

resource "null_resource" "wait_for_lambda_package" {
  provisioner "local-exec" {
    command = <<EOF
ls -lrt "${local.transform_archive_path}"
EOF
  }
  triggers = {
    depends = null_resource.build_lambda_transform_package.id
  }
}
data "archive_file" "lambda_package" {
  type        = "zip"
  source_dir  = local.lambda_transform_dir
  output_path = local.transform_archive_path

  depends_on = [
    null_resource.wait_for_lambda_package
  ]
}