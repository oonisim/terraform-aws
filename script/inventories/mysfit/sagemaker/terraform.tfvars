#--------------------------------------------------------------------------------
# SageMaker instance
#--------------------------------------------------------------------------------
#sagemaker_name = "fraud-detection"
sagemaker_name          = "mysfit-recommendation-knn"
sagemaker_instance_type = "ml.t2.medium"

#--------------------------------------------------------------------------------
# SageMaker algorithm
#--------------------------------------------------------------------------------
sagemaker_algorithm_name = "knn"

# AWS accoutn of Docker image ECR
sagemaker_ecr_account = {
  knn     = {
    us-west-1      = "632365934929"
    us-west-2      = "174872318107"
    us-east-2      = "404615174143"
    ap-southeast-2 = "712309505854"
  }
  xgboost = {
    us-west-1      = "746614075791"
    us-west-2      = "246618743249"
    us-east-2      = "257758044811"
    ap-southeast-2 = "783357654285"
  }
}

#--------------------------------------------------------------------------------
# Jupyter notebook and its version to run ML training
#--------------------------------------------------------------------------------
#jupyter_notbook_name = "sagemaker_fraud_detection.ipynb"
sagemaker_notebook_name = "mysfit_recommendations_knn.ipynb"
function_version        = "v1"

#--------------------------------------------------------------------------------
# SageMaker endpoint instance type
#--------------------------------------------------------------------------------
sagemaker_endpoint_name = "mysfit_recommendation_knn_endpoint"
