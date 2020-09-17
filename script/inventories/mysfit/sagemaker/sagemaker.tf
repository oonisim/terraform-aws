resource "aws_sagemaker_notebook_instance" "this" {
  name                  = replace("${var.PROJECT}_${var.ENV}_sagemaker_intance_${var.sagemaker_name}", "/[_.@~*&%= ]/", "-")
  role_arn              = aws_iam_role.sagemaker.arn
  instance_type         = var.sagemaker_instance_type
  lifecycle_config_name = aws_sagemaker_notebook_instance_lifecycle_configuration.this.name

  tags = {
    Project     = var.PROJECT
    Environment = var.ENV
    # To create a TF dependency on S3 bucket to make sure the bucker existence
    Bucket      = local.bucket_sagemaker_notebook_name
  }
}
resource "aws_sagemaker_notebook_instance_lifecycle_configuration" "this" {
  name      = replace("${var.PROJECT}_${var.ENV}_sagemaker_lc_${var.sagemaker_name}", "/[_.@~*&%= ]/", "-")
  #on_start = "${base64encode(data.template_file.instance_init.rendered)}"
  on_create = base64encode(templatefile("${path.module}/template/sagemaker_instance_init.sh", {
    data_bucket_name        = local.bucket_sagemaker_data_name
    function_bucket_name    = aws_s3_bucket_object.sagemaker_notebook.bucket
    function_bucket_key     = aws_s3_bucket_object.sagemaker_notebook.key
    sagemaker_notebook_name = var.sagemaker_notebook_name
  }
  ))
  depends_on = [
    aws_s3_bucket_object.sagemaker_notebook
  ]
}

# Cannot create a SageMaker endpoint from a model data in S3 bucket.
# https://stackoverflow.com/questions/60882362/sagemaker-clarification-on-sagemaker-entities-in-cloudformation
/*
resource "aws_sagemaker_model" "knn" {
  name               = "${var.PROJECT}-${var.ENV}-sagemaker-model-knn-${var.sagemaker_name}"
  execution_role_arn = aws_iam_role.sagemaker.arn
  primary_container {
    # Example: "174872318107.dkr.ecr.us-west-2.amazonaws.com/kmeans:1"
    image = "${var.sagemaker_ecr_account[${var.sagemaker_algorithm_name}][${data.aws_region.current.id}]}.dkr.ecr.${data.aws_region.current.id}.amazonaws.com/${var.sagemaker_algorithm_name}:${var.sagemaker_algorithm_version}"
  }

  tags = {
    Project     = var.PROJECT
    Environment = var.ENV
    Algorithm   = var.sagemaker_algorithm_name
  }
}

resource "aws_sagemaker_endpoint_configuration" "knn" {
  name = "${var.PROJECT}-${var.ENV}-sagemaker-endpoint-configuration-${var.sagemaker_name}"
  production_variants {
    variant_name           = "variant-1"
    model_name             = aws_sagemaker_model.knn.name
    initial_instance_count = 1
    instance_type          = "ml.t2.medium"
  }
}

resource "aws_sagemaker_endpoint" "knn" {
  name                 = "${var.PROJECT}-${var.ENV}-sagemaker-endpoint-${var.sagemaker_name}"
  endpoint_config_name = aws_sagemaker_endpoint_configuration.knn.name
}


# Expose I/F
locals {
  sagemaker_model_name        = aws_sagemaker_model.knn.name
  sagemaker_model_arn         = aws_sagemaker_model.knn.arn
  sagemaker_model_id          = aws_sagemaker_model.knn.id
  sagemaker_endpoint_knn_name = aws_sagemaker_endpoint.knn.name
  sagemaker_endpoint_knn_arn  = aws_sagemaker_endpoint.knn.arn
  sagemaker_endpoint_knn_id   = aws_sagemaker_endpoint.knn.id
}
*/