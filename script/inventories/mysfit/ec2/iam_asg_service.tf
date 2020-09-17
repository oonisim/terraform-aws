#================================================================================
# TODO: Limt the resources to grant access. Currenty "*".
#================================================================================

locals {
  ec2_ecs_service_sid = "ASGChatService"
  bucket_data_arn = "${data.terraform_remote_state.s3.outputs.bucket_data_arn}"
}

#--------------------------------------------------------------------------------
# ASG ECS instance profile
#--------------------------------------------------------------------------------
resource "aws_iam_instance_profile" "ec2_ecs_service" {
  name = "${var.PROJECT}_${var.ENV}_ec2_ecs_service"
  path = "/"
  role = aws_iam_role.ec2_ecs_service.name
}

#--------------------------------------------------------------------------------
# ASG EC2 Instanace Role
#--------------------------------------------------------------------------------
resource "aws_iam_role" "ec2_ecs_service" {
  name                = "${var.PROJECT}_${var.ENV}_ec2_ecs_service"
  path                = "/"
  assume_role_policy  = "${data.aws_iam_policy_document.allow_ec2_ecs_service_assume_ec2.json}"
}

data "aws_iam_policy_document" "allow_ec2_ecs_service_assume_ec2" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

#--------------------------------------------------------------------------------
# Permission to call ECS
#--------------------------------------------------------------------------------
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/get-set-up-for-amazon-ecs.html#create-an-iam-role
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/instance_IAM_role.html
# For tasks using the EC2 launch type, the IAM role that allows the ECS agent to know
# which account it should register your container instances with.
# When you launch a container instance with the Amazon ECS-optimized AMI provided by
# Amazon using this role, the agent automatically registers the container instance into the default cluster.
#--------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "allow_ec2_ecs_service_access_ec2" {
  role       = aws_iam_role.ec2_ecs_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "allow_ec2_ecs_service_ecs_task" {
  role       = aws_iam_role.ec2_ecs_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
resource "aws_iam_role_policy_attachment" "allow_ec2_ecs_service_power_ecr" {
  role       = aws_iam_role.ec2_ecs_service.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}
resource "aws_iam_role_policy_attachment" "allow_ec2_ecs_service_full_ecr" {
  role       = aws_iam_role.ec2_ecs_service.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}
#--------------------------------------------------------------------------------
# Session Manager
#--------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "allow_ec2_ecs_service_use_ssm" {
  role       = aws_iam_role.ec2_ecs_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}
#--------------------------------------------------------------------------------
# IAM policy allow S3 access
#--------------------------------------------------------------------------------
resource "aws_iam_role_policy" "allow_ec2_ecs_service_access_s3" {
  name   = "${title(var.PROJECT)}${title(var.ENV)}Allow${title(local.ecs_cluster_name)}Access_s3"
  role   = aws_iam_role.ec2_ecs_service.id
  policy = data.aws_iam_policy_document.allow_ec2_ecs_service_access_s3.json
}

data "aws_iam_policy_document" "allow_ec2_ecs_service_access_s3" {
  statement {
    sid    = replace("${title(var.PROJECT)}${title(var.ENV)}Allow${local.ec2_ecs_service_sid}AccessS3", "/[-_.]/", "")
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:Put*",
      "s3:List*",
      "s3:*MultipartUpload*",
      "s3:PutBucketAcl",
      "s3:PutObjectAcl",
    ]

    resources = [
      "${local.bucket_data_arn}",
      "${local.bucket_data_arn}/*",
    ]
  }
  statement {
    sid    = replace("${title(var.PROJECT)}${title(var.ENV)}Deny${local.ec2_ecs_service_sid}AlterS3", "/[-_.]/", "")
    effect = "Deny"
    actions = [
      "s3:*Delete*",
      "s3:*Policy*",
    ]
    resources = [
      "*",
    ]
  }
}

#--------------------------------------------------------------------------------
# Permission to access EFS
# https://docs.aws.amazon.com/efs/latest/ug/efs-api-permissions-ref.html
# https://docs.aws.amazon.com/efs/latest/ug/access-control-managing-permissions.html
# https://console.aws.amazon.com/iam/home?#/policies/arn:aws:iam::aws:policy/AmazonElasticFileSystemReadOnlyAccess$jsonEditor
#--------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "allow_ec2_ecs_service_read_efs" {
  role       = aws_iam_role.ec2_ecs_service.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemReadOnlyAccess"
}
resource "aws_iam_role_policy" "allow_ec2_ecs_service_access_efs" {
  name   = replace("${var.PROJECT}_${var.ENV}_allow_${local.ecs_cluster_name}_access_efs", "/[-_.]/", "")
  role   = aws_iam_role.ec2_ecs_service.id
  policy = data.aws_iam_policy_document.allow_ec2_ecs_service_access_efs.json
}

data "aws_iam_policy_document" "allow_ec2_ecs_service_access_efs" {
  statement {
    sid    = replace("${title(var.PROJECT)}${title(var.ENV)}Allow${local.ec2_ecs_service_sid}AccessEFS", "/[-_.]/", "")
    effect = "Allow"
    actions = [
      "elasticfilesystem:CreateMountTarget",
      "elasticfilesystem:CreateTags",
      "elasticfilesystem:Describe*",
    ]

    resources = [
      "arn:aws:elasticfilesystem:${var.REGION}:${data.aws_caller_identity.current.account_id}:file-system/*"
    ]
  }
  statement {
    sid    = replace("${title(var.PROJECT)}${title(var.ENV)}Allow${local.ec2_ecs_service_sid}MountEFSOnEC2", "/[-_.]/", "")
    effect = "Allow"
    actions = [
      "ec2:DescribeSubnets",
      "ec2:CreateNetworkInterface",
      "ec2:Describe*"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid    = replace("${title(var.PROJECT)}${title(var.ENV)}Deny${local.ec2_ecs_service_sid}AlterEFS", "/[-_.]/", "")
    effect = "Deny"
    actions = [
      "elasticfilesystem:DeleteFileSystem*",
    ]
    resources = [
      "*"
    ]
  }
}

locals {
  ec2_ecs_service_instance_profile_name = "${aws_iam_instance_profile.ec2_ecs_service.name}"
}

#--------------------------------------------------------------------------------
# IAM policy to assume access Dynamo.
# https://aws.amazon.com/blogs/security/how-to-create-an-aws-iam-policy-to-grant-aws-lambda-access-to-an-amazon-dynamodb-table/
# https://www.olicole.net/blog/2017/07/terraforming-aws-a-serverless-website-backend-part-1/
#--------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "allow_ec2_ecs_service_access_dynamodb" {
  role       = aws_iam_role.ec2_ecs_service.name
  policy_arn = aws_iam_policy.allow_ec2_ecs_service_access_dynamodb.arn
}

resource "aws_iam_policy" "allow_ec2_ecs_service_access_dynamodb" {
  name_prefix = "${title(var.PROJECT)}${title(var.ENV)}_Allow${title(local.ec2_ecs_service_sid)}AccessDynamoDB"
  policy      = data.aws_iam_policy_document.allow_ec2_ecs_service_access_dynamodb.json
}

data "aws_iam_policy_document" "allow_ec2_ecs_service_access_dynamodb" {
  statement {
    sid    = replace("${title(var.PROJECT)}${title(var.ENV)}Allow${local.ec2_ecs_service_sid}AccessDynamoDB", "/[-_.]/", "")
    effect = "Allow"
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:BatchWriteItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
    ]
    resources = [
      #var.dynamo_table_arn,
      #"${var.dynamo_table_arn}/*", # index
      "*"
    ]
  }
}