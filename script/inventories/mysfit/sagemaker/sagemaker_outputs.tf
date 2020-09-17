/*
locals {
  sagemaker_model_arn         = aws_sagemaker_model.knn.arn
  sagemaker_model_id          = aws_sagemaker_model.knn.id
  sagemaker_endpoint_knn_name = aws_sagemaker_endpoint.knn.name
  sagemaker_endpoint_knn_arn  = aws_sagemaker_endpoint.knn.arn
  sagemaker_endpoint_knn_id   = aws_sagemaker_endpoint.knn.id
}

output "sagemaker_model_name" {
  value = local.sagemaker_model_name
}
output "sagemaker_model_arn" {
  value = local.sagemaker_model_arn
}
output "sagemaker_model_id" {
  value = local.sagemaker_model_id
}

output "sagemaker_endpoint_knn_name" {
  value = local.sagemaker_endpoint_knn_name
}
output "sagemaker_endpoint_knn_arn" {
  value = local.sagemaker_endpoint_knn_arn
}
output "sagemaker_endpoint_knn_id" {
  value = local.sagemaker_endpoint_knn_id
}
*/
output "sagemaker_iam_policy" {
  value = aws_iam_policy.allow_sagemaker_access_aws.policy
}

#--------------------------------------------------------------------------------
# SageMaker instance
#--------------------------------------------------------------------------------
output "sagemaker_notebook_instance_type" {
  value = aws_sagemaker_notebook_instance.this.instance_type
}
output "sagemaker_notebook_instance_id" {
  value = aws_sagemaker_notebook_instance.this.id
}
output "sagemaker_recommendation_endpoint_name" {
  value = ""
}

#--------------------------------------------------------------------------------
# SageMaker endpoint
#--------------------------------------------------------------------------------
output "sagemaker_endpoint_name" {
  value = var.sagemaker_endpoint_name
}
