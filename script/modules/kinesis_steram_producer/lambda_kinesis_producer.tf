#================================================================================
# Lambda kinesis producer
# [Objective]
# Stream data into Kinesis stream
#================================================================================

locals {
  lambda_kinesis_producer_trigger     = "${local.module_path}/${var.lambda_kinesis_producer_trigger}"
  lambda_kinesis_producer_dir         = "${local.module_path}/${var.lambda_kinesis_producer_dir}"
  lambda_kinesis_producer_archive_dir = "${local.module_path}/${var.lambda_kinesis_producer_archive_dir}"
}

#--------------------------------------------------------------------------------
# Load the template file for lambda.
# Data sources get executed at the beginning of DAG. Resouces cannot depend on them.
# [Note]
# The dependency must be injected, not be reference to eliminate hidden dependency
# embedded/hard-coded in the service consumer side.
#--------------------------------------------------------------------------------
data "template_file" "lambda_kinesis_producer" {
  template = "${file("${local.lambda_kinesis_producer_dir}/${var.lambda_kinesis_producer_template}")}"
  vars = {
    bucket_region           = "${data.aws_s3_bucket.upload.region}"
    bucket_name             = "${data.aws_s3_bucket.upload.bucket}"
    stream_name             = "${var.kinesis_stream_name}"
  }
}

#--------------------------------------------------------------------------------
# Templating - Lambda Function
#--------------------------------------------------------------------------------
resource "local_file" "kinesis_producer_py" {
  content  = "${data.template_file.lambda_kinesis_producer.rendered}"
  filename = "${local.module_path}/${var.lambda_kinesis_producer_dir}/${var.lambda_kinesis_producer_file}"
}
locals {
  lambda_kinesis_producer_archive_name = "${replace(basename(local_file.kinesis_producer_py.filename), ".py", "")}"
  lambda_kinesis_producer_archive_path = "${local.lambda_kinesis_producer_archive_dir}/${local.lambda_kinesis_producer_archive_name}.zip"
}

resource "null_resource" "build_lambda_kinesis_producer_package" {
  provisioner "local-exec" {
    command = "ls ${local_file.kinesis_producer_py.filename}"
  }
  provisioner "local-exec" {
    command=<<EOF
      chmod    ugo+rx ${local.lambda_kinesis_producer_dir}
      chmod -R ugo+r  ${local.lambda_kinesis_producer_dir}/*
EOF
  }
  provisioner "local-exec" {
    #--------------------------------------------------------------------------------
    # [Note]
    # Files in the zip file MUST be readable by anyone to be exectued as lambda.
    # To force re-uplaod, change the content of the trigger file.
    #--------------------------------------------------------------------------------
    command=<<EOF
      ./setup.sh
      zip -vr ${local.lambda_kinesis_producer_archive_path} *  -x \"*.template\"
EOF
    working_dir = "${local.lambda_kinesis_producer_dir}"
  }

  #--------------------------------------------------------------------------------
  # Regenerate lambda function package upon the change of the files.
  #--------------------------------------------------------------------------------
  triggers = {
    #producer  = "${md5(file(local_file.kinesis_producer_py.filename))}"
    trigger   = "${md5(file(local.lambda_kinesis_producer_trigger))}"
    archive   = "${md5(file(local.lambda_kinesis_producer_archive_path))}"
  }
}

resource "aws_s3_bucket_object" "lambda_kinesis_producer_package" {
  bucket                 = "${data.aws_s3_bucket.upload.bucket}"
  key                    = "${local.lambda_kinesis_producer_archive_name}.zip"
  #storage_class          = "GLACIER
  storage_class          = "STANDARD_IA"
  #server_side_encryption = "AES256"

  source                 = "${local.lambda_kinesis_producer_archive_path}"

  #--------------------------------------------------------------------------------
  # etag fails if there is no target object to upload exists for the first time.
  # Create a dummpy/empty object.
  #
  # To force re-uplaod, change the content of the trigger file.
  #--------------------------------------------------------------------------------
  etag                   = "${md5(file(local.lambda_kinesis_producer_archive_path))}"

  depends_on = [
    "null_resource.build_lambda_kinesis_producer_package"
  ]
}

#--------------------------------------------------------------------------------
# Lambda
#--------------------------------------------------------------------------------
#--------------------------------------------------------------------------------
# The mandatory role and policy for lambda is in the tf file of the lambda
#--------------------------------------------------------------------------------
resource "aws_iam_role" "lambda_kinesis_producer" {
  name               = "${var.PROJECT}_lambda_kinesis_producer"
  description        = "Role for lambda to assume"
  assume_role_policy = "${data.aws_iam_policy_document.assume_lambda_service.json}"
}

resource "aws_lambda_function" "kinesis_producer" {
  function_name      = "${var.lambda_kinesis_producer_name}"
  #--------------------------------------------------------------------------------
  # To avoid "Error creating Lambda function: timeout while waiting for state to become 'success' (timeout: 1m0s)"
  # https://forums.developer.amazon.com/questions/31047/lambda-function-timeout.html
  #--------------------------------------------------------------------------------
  s3_bucket          = "${data.aws_s3_bucket.upload.bucket}"
  s3_key             = "${aws_s3_bucket_object.lambda_kinesis_producer_package.key}"
  #--------------------------------------------------------------------------------

  #--------------------------------------------------------------------------------
  # Need to detect the code change with source_code_hash.
  # https://github.com/hashicorp/terraform/issues/5150
  #
  # Need to make sure of zip with output_base64sha256 (output_sha not work)
  # https://github.com/hashicorp/terraform/issues/6513
  #--------------------------------------------------------------------------------
  source_code_hash  = "${md5(file(local.lambda_kinesis_producer_archive_path))}"
  role              = "${aws_iam_role.lambda_kinesis_producer.arn}"
  handler           = "${var.lambda_kinesis_producer_handler}"
  runtime           = "${var.lambda_kinesis_producer_runtime}"

  depends_on = [
    "aws_s3_bucket_object.lambda_kinesis_producer_package",
  ]
}
resource "aws_lambda_alias" "kinesis_producer" {
  name             = "latest"
  description      = "Alias to lambda_kinesis_producer"
  function_name    = "${aws_lambda_function.kinesis_producer.arn}"
  function_version = "${var.lambda_kinesis_producer_function_version}"
}

data "aws_lambda_function" "kinesis_producer" {
  function_name = "${aws_lambda_alias.kinesis_producer.function_name}"
  qualifier     = "${aws_lambda_alias.kinesis_producer.name}"
}

#--------------------------------------------------------------------------------
# Lambda alias invocation ARN.
# Invoke lambda via alias, NOT directly the function itself.
# https://github.com/terraform-providers/terraform-provider-aws/issues/4479
#--------------------------------------------------------------------------------
locals {
  lambda_kinesis_producer_invoke_arn = "${data.aws_lambda_function.kinesis_producer.invoke_arn}"
}
