locals {
  process_question_dir               = "${local.module_path}/${var.lambda_process_question_dir}/${var.lambda_process_question_alias_name}"
  process_question_file_path         = "${local.process_question_dir}/${var.lambda_process_question_file_name}"
  process_question_trigger_path      = "${local.process_question_dir}/trigger"
  process_question_requirements_path = "${local.process_question_dir}/requirements.txt"
  process_question_archive_path      = "${local.module_path}/${var.lambda_process_question_package_dir}/${var.lambda_process_question_alias_name}/${var.lambda_process_question_archive_name}"
}

resource "null_resource" "setup_lambda_process_question_package" {
  provisioner "local-exec" {
    command     = <<EOF
      bash ./setup.sh
EOF
    working_dir = local.process_question_dir
  }
  #--------------------------------------------------------------------------------
  # Lambda files needs to be readable by other for Lambda runtime account to run them.
  # The executable files needs to have x permission.
  #--------------------------------------------------------------------------------
  provisioner "local-exec" {
    command = <<EOF
      chmod    ugo+rx ${local.process_question_dir}
      chmod -R ugo+r  ${local.process_question_dir}/*
EOF

  }
  provisioner "local-exec" {
    command     = <<EOF
      mkdir -p ${dirname(local.process_question_archive_path)}
EOF
    working_dir = local.process_question_dir
  }

  #--------------------------------------------------------------------------------
  # Regenerate lambda function package upon the change of the files.
  # Those trigger contents need to be changed before terraform apply to be able to trigger.
  #--------------------------------------------------------------------------------
  triggers = {
    requirements = filemd5(local.process_question_requirements_path)
    trigger      = filemd5(local.process_question_trigger_path)
  }
}

#--------------------------------------------------------------------------------
# To wait for null_resource
# https://github.com/hashicorp/terraform/issues/18303
#--------------------------------------------------------------------------------
resource "null_resource" "wait_for_lambda_process_question_setup" {
  provisioner "local-exec" {
    command = <<EOF
pwd
EOF
  }
  triggers = {
    depends = null_resource.setup_lambda_process_question_package.id
  }
}
data "archive_file" "lambda_process_question_package" {
  type        = "zip"
  source_dir  = local.process_question_dir
  output_path = local.process_question_archive_path

  depends_on = [
    null_resource.wait_for_lambda_process_question_setup
  ]
}