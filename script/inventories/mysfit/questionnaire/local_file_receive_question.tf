locals {
  receive_question_dir               = "${local.module_path}/${var.lambda_receive_question_dir}/${var.lambda_receive_question_alias_name}"
  receive_question_file_path         = "${local.receive_question_dir}/${var.lambda_receive_question_file_name}"
  receive_question_template_path     = "${local.receive_question_dir}/${var.lambda_receive_question_template_name}"
  receive_question_trigger_path      = "${local.receive_question_dir}/trigger"
  receive_question_requirements_path = "${local.receive_question_dir}/requirements.txt"
  receive_question_archive_path      = "${local.module_path}/${var.lambda_receive_question_package_dir}/${var.lambda_receive_question_alias_name}/${var.lambda_receive_question_archive_name}"
}

resource "local_file" "lambda_receive_question_py" {
  content  = templatefile(
    local.receive_question_template_path,
    {
      dynamodb_table_name = var.dynamodb_table_name
    }
  )
  filename = local.receive_question_file_path
}

locals {
  lambda_receive_question_dir = dirname(local_file.lambda_receive_question_py.filename)
}

resource "null_resource" "setup_lambda_receive_question_package" {
  provisioner "local-exec" {
    command     = <<EOF
      bash ./setup.sh
EOF
    working_dir = local.lambda_receive_question_dir
  }
  #--------------------------------------------------------------------------------
  # Lambda files needs to be readable by other for Lambda runtime account to run them.
  # The executable files needs to have x permission.
  #--------------------------------------------------------------------------------
  provisioner "local-exec" {
    command = <<EOF
      chmod    ugo+rx ${local.lambda_receive_question_dir}
      chmod -R ugo+r  ${local.lambda_receive_question_dir}/*
EOF

  }

  #       zip -vr "${local.receive_question_archive_path}" *  -x \"*.template\"
  provisioner "local-exec" {
    command     = <<EOF
      mkdir -p ${dirname(local.receive_question_archive_path)}
EOF
    working_dir = local.lambda_receive_question_dir
  }

  #--------------------------------------------------------------------------------
  # Regenerate lambda function package upon the change of the files.
  # Those trigger contents need to be changed before terraform apply to be able to trigger.
  #--------------------------------------------------------------------------------
  triggers = {
    # Lambda function
    template            = filemd5(local.receive_question_template_path)
    # Python requirements
    requirements        = filemd5(local.receive_question_requirements_path)
    # Patameter values
    dynamodb_table_name = var.dynamodb_table_name
    # Trigger file
    trigger             = filemd5(local.receive_question_trigger_path)
  }

  depends_on = [
    local_file.lambda_receive_question_py
  ]
}

#--------------------------------------------------------------------------------
# To wait for null_resource
# https://github.com/hashicorp/terraform/issues/18303
#--------------------------------------------------------------------------------
resource "null_resource" "wait_for_lambda_receive_question_package" {
  provisioner "local-exec" {
    command = <<EOF
pwd
EOF
  }
  triggers = {
    depends = null_resource.setup_lambda_receive_question_package.id
  }
}
data "archive_file" "lambda_receive_question_package" {
  type        = "zip"
  source_dir  = local.lambda_receive_question_dir
  output_path = local.receive_question_archive_path

  depends_on = [
    null_resource.wait_for_lambda_receive_question_package
  ]
}