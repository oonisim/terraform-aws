cd /home/ec2-user/SageMaker
aws s3 cp s3://${function_bucket_name}/${function_bucket_key} .
sed -i 's/fraud-detection-end-to-end-demo/${data_bucket_name}/g' "${sagemaker_notebook_name}"