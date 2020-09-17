#--------------------------------------------------------------------------------
# Upload the Jupyoter notebook to S3 (Lifecycle configuration Script take it to the Notebook instance)
#--------------------------------------------------------------------------------
resource "aws_s3_bucket_object" "sagemaker_notebook" {
  bucket = local.bucket_sagemaker_notebook_name
  key    = "${var.sagemaker_name}/${var.function_version}/notebooks/${var.sagemaker_notebook_name}"
  source = "${path.module}/notebooks/${var.sagemaker_notebook_name}"
  etag   = filemd5("${path.module}/notebooks/${var.sagemaker_notebook_name}")
}
