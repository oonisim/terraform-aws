resource "aws_iam_role" "sagemaker" {
  name = substr("${var.PROJECT}-${var.ENV}-sagemaker-instance-${var.sagemaker_name}", 0, var.AWS_IDENTIFIER_NAME_LENGTH_MAX)
  assume_role_policy = data.aws_iam_policy_document.assume_sagemaker_service.json
  tags = {
    Project = var.PROJECT
    Environment = var.ENV
  }
}
data "aws_iam_policy_document" "assume_sagemaker_service" {
  statement {
    sid    = replace("${title(lower(var.PROJECT))}${title(lower(var.ENV))}AssumeSageMaker", "/[_.@~*&%= ]/", "")
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "sagemaker.amazonaws.com",
      ]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "allow_sagemaker_access_aws" {
  role       = aws_iam_role.sagemaker.name
  policy_arn = aws_iam_policy.allow_sagemaker_access_aws.arn
}

#--------------------------------------------------------------------------------
# SageMaker IAM Role
# [SageMaker default bucket]
# The default S3 bucket for this session will be created. If not provided,
# a default bucket will be created based on the following format:
# “sagemaker-{region}-{aws-account-id}”.
# https://sagemaker.readthedocs.io/en/stable/session.html
#--------------------------------------------------------------------------------
#                 "arn:aws:ecr:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:repository/*"
resource "aws_iam_policy" "allow_sagemaker_access_aws" {
  name        = replace("${title(lower(var.PROJECT))}${title(lower(var.ENV))}AllowSageMakerAccessAWS", "/[_.@~*&%= ]/", "")
  description = "Policy for the Notebook Instance to manage training jobs, models and endpoints"
  path        = "/"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketLocation",
                "s3:ListBucket",
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "${local.bucket_sagemaker_notebook_arn}",
                "${local.bucket_sagemaker_notebook_arn}/*",
                "${local.bucket_sagemaker_data_arn}",
                "${local.bucket_sagemaker_data_arn}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:CreateBucket",
                "s3:DeleteBucket",
                "s3:ListBucket",
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": [
              "arn:aws:s3:::sagemaker-${data.aws_region.current.id}-${data.aws_caller_identity.current.account_id}",
              "arn:aws:s3:::sagemaker-${data.aws_region.current.id}-${data.aws_caller_identity.current.account_id}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "sagemaker:CreateTrainingJob",
                "sagemaker:DescribeTrainingJob",
                "sagemaker:CreateModel",
                "sagemaker:DescribeModel",
                "sagemaker:DeleteModel",
                "sagemaker:CreateEndpoint",
                "sagemaker:CreateEndpointConfig",
                "sagemaker:DescribeEndpoint",
                "sagemaker:DescribeEndpointConfig",
                "sagemaker:DeleteEndpoint"
            ],
            "Resource": [
                "arn:aws:sagemaker:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability"
            ],
            "Resource": [
                "arn:aws:ecr:us-east-2:404615174143:repository/404615174143.dkr.ecr.us-east-2.amazonaws.com/knn:1"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateVpcEndpoint",
                "ec2:DescribeRouteTables"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricData",
                "cloudwatch:GetMetricData",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:ListMetrics"
            ],
            "Resource": [
                "arn:aws:cloudwatch:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogStreams",
                "logs:GetLogEvents",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:log-group:/aws/sagemaker/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:PassRole"
            ],
            "Resource": [
                "${aws_iam_role.sagemaker.arn}"
            ],
            "Condition": {
                "StringEquals": {
                    "iam:PassedToService": "sagemaker.amazonaws.com"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:GetRole"
            ],
            "Resource": [
                "${aws_iam_role.sagemaker.arn}"
            ]
        }
    ]
}
EOF
}
