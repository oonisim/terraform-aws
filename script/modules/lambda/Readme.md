# Overview

Terraform module to upload lambda package and create a lambda function.

## Arguments
- S3 bucket name 
- Lambda package path
- Lambda file name 
- Lambda handler name
- IAM role name for Lambda to assume, and to which attach policies needed
- Lambda function name to use
- Lambda alias to create
- Lambda version to crete
- Lambda runtime environment (e.g Python3.6)
- Lambda memory size (Lambda core scales according to the memory size allocated)
- Lambda timeout (in seconds)

# TODO
 * Lambda in VPC <br/>
  Firehose VPC Endpoint as in https://docs.aws.amazon.com/firehose/latest/dev/vpc.html


# Reference

* Hashicorp [Serverless Applications with AWS Lambda and API Gateway](https://learn.hashicorp.com/terraform/aws/lambda-api-gateway#a-new-version-of-the-lambda-function)