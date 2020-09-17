variable "sagemaker_notebook_name" {
  description = "Name of the SageMaker jupyter notebook file to run in the SageMaker instance"
  type = string
}
variable "sagemaker_name" {
  description = "Name of the SageMaker"
  type = string
}
variable "sagemaker_instance_type" {
  description = "EC2 instance type for the Sagemaker instance"
  type = string
}
variable "function_version" {
  description = "Version to use."
  type = string
}

variable "sagemaker_algorithm_name" {
  # https://docs.aws.amazon.com/sagemaker/latest/dg/sagemaker-algo-docker-registry-paths.html
  description = "Name of the SageMaker algorithm to use which identifies the docker image in ECR."
}
variable "sagemaker_algorithm_version" {
  # use the :1 version tag to ensure that you are using a stable version of the algorithm.
  # You can reliably host a model using an image with the :1 tag on an inference image that has the :1 tag.
  # https://docs.aws.amazon.com/sagemaker/latest/dg/sagemaker-algo-docker-registry-paths.html
  description = "Version of the SageMaker docker image of the algorithm"
  type = string
  default = "1"
}
variable "sagemaker_ecr_account" {
  # See https://docs.aws.amazon.com/sagemaker/latest/dg/sagemaker-algo-docker-registry-paths.html
  description = "The AWS account ID in which the ECR repository for the target ML algorithm is stored."
  type = map(map(string))
}

# TODO: Dynamically set the SageMaker endpoint name in jupyetr notebook.
variable "sagemaker_endpoint_name" {
  default = "Name of the SageMaker endpoint"
  type = string
}