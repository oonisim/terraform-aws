# AWS platform setup using Terraform

## Restriction

To configure API Gateway permission to invoke Lambda, [aws_lambda_permission](https://www.terraform.io/docs/providers/aws/r/lambda_permission.html) which requires pre-existing lambda functions

```
# Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda.arn}"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.myregion}:${var.accountId}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.method.http_method}/${aws_api_gateway_resource.resource.path}"
}
```


https://www.terraform.io/docs/providers/aws/r/api_gateway_integration.html


## Directory Structure

```
├── inventories   <--- Environment
│   ├── dev
│   ├── prd
│   ├── Readme.md
│   └── uat
├── modules       <--- Terraform module directory
│   ├── apigw
│   ├── consumer
│   ├── dynamodb
│   ├── executor
│   ├── nacl
│   ├── policy
│   ├── producer
│   ├── rds
│   ├── s3
│   └── user
├── Readme.md
├── run.sh        <--- Runner program to execute to setup the Terraform scripts
└── scripts       <--- Additional setup scripts to aid the AWS platform setup.
    ├── backend
    ├── cognito
    └── mfa
```

# Preprations

## Terraform
#### Terraform backend
Create a S3 backend for each inventory before creating AWS resources for the environment.
```dtd
terraform/scripts/backend/create.sh
```

#### Terraform plugins
To avoid downloading multiple times, pre-download the plugins.
```dtd
terraform/plugins/run.sh
```

## Docker
Create a docker group and change the groupp owner of the docker socket to the group. Note that this could be a security issue.
```dtd
$ ls -lrta /var/run/docker.sock
srw-rw---- 1 root docker 0 Feb  6 14:11 /var/run/docker.sock
```

Place the user of the terraform in the docker group so that terraform can access the docker socket to run docker operations.
```dtd
sudo groupadd docker
sudo usermod -a -G docker ${USER}
```

Otherwise the error.
```dtd
(local-exec): Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock
```

Make sure to test docker command and verify the permission.
```dtd
# example
docker images
```

## AWS
Set the AWS environment variables. 
```
AWS_DEFAULT_REGION
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_SECURITY_DEVICE_ARN # for MFA
```

In case of MFA is enabled and to be used, get a temporal session token from STS s in the script.
```dtd
terraform/scripts/mfa/aws_mfa_setup.sh
```

## Nodejs
```dtd
sudo apt install nodejs npm
```

# Run

```dtd
terraform/run.sh
```

