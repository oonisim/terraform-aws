#--------------------------------------------------------------------------------
# VPC
#--------------------------------------------------------------------------------
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  # Error: Variables not allowed
  #version = var.terraform_aws_modules_version

  name   = "${var.PROJECT}_${var.ENV}"
  cidr   = var.vpc_cidr

  azs                 = data.aws_availability_zones.all.names
  private_subnets     = var.private_subnets
  public_subnets      = var.public_subnets
  intra_subnets       = var.intra_subnets
  database_subnets    = var.database_subnets
  redshift_subnets    = var.redshift_subnets
  elasticache_subnets = var.elasticache_subnets

  # Reqired true for VPC peering hostname resolution.
  # See https://www.terraform.io/docs/providers/aws/r/vpc_peering_options.html
  enable_nat_gateway = var.enable_nat_gateway

  #--------------------------------------------------------------------------------
  # The VPC module has the restriction that the number of AZ must be less than
  # the number of publc subnet so that all NAT will be used with public subnets.
  # The logic is in main.tf as below.
  #   resource "aws_subnet" "public" {
  #     count = "${var.create_vpc && length(var.public_subnets) > 0 &&
  #     (!var.one_nat_gateway_per_az || length(var.public_subnets) >= length(var.azs))
  #     ? length(var.public_subnets) : 0}"
  #
  # Therefore, if the nummber of AZ > number of public subnets, DO NOT use the flag.
  # For example, us-east-1 has 6 AZ.
  #   data.aws_availability_zones.all:
  #   id = 2018-10-20 11:50:05.2890622 +0000 UTC
  #   names.# = 6
  #   names.0 = us-east-1a
  #   names.1 = us-east-1b
  #   names.2 = us-east-1c
  #   names.3 = us-east-1d
  #   names.4 = us-east-1e
  #   names.5 = us-east-1f
  #
  # It will cause the error because the number of public subnet count is set to 0 if
  # AZ num > pubic subnet num.
  #   * module.vpc.aws_nat_gateway.this[3]: element: element() may not be used with an empty list in:
  #   ${element(aws_subnet.public.*.id, (var.single_nat_gateway ? 0 : count.index))}
  #--------------------------------------------------------------------------------
  #one_nat_gateway_per_az        = true
  #--------------------------------------------------------------------------------

  #--------------------------------------------------------------------------------
  # VPC S3 endpoint
  #--------------------------------------------------------------------------------
  enable_s3_endpoint = var.enable_s3_endpoint

  #--------------------------------------------------------------------------------
  # VPC DynamoDB endpoint
  # https://aws.amazon.com/blogs/aws/new-vpc-endpoints-for-dynamodb/
  # https://aws.amazon.com/blogs/database/how-to-configure-a-private-network-environment-for-amazon-dynamodb-using-vpc-endpoints/
  #--------------------------------------------------------------------------------
  enable_dynamodb_endpoint = var.enable_dynamodb_endpoint

  #--------------------------------------------------------------------------------
  # DNS
  # [VPC endpoints]
  # Endpoint require DNS to route requests to the required service (e.g. S3)
  # are resolved correctly to the IP addresses maintained by AWS.
  # Be sure DNS resolution is set to yes in the VPC console.
  # https://docs.aws.amazon.com/vpc/latest/userguide/vpc-endpoints.html
  # https://docs.aws.amazon.com/vpc/latest/userguide/vpce-gateway.html#vpc-endpoints-limitations
  # https://aws.amazon.com/premiumsupport/knowledge-center/connect-s3-vpc-endpoint/
  #
  # [Private DNS]
  # https://docs.aws.amazon.com/vpc/latest/userguide/vpce-interface.html#vpce-private-dns
  # To use private DNS, you must set the following VPC attributes to true:
  # enableDnsHostnames and enableDnsSupport.
  #
  # VPC DNS support will enable public DNS. To avoid EC2 instance to have public
  # DNS/IP, set AssociatePublicIpAddress for run_instance API.
  # NetworkInterfaces=[
  #   {  'AssociatePublicIpAddress': False,
  #--------------------------------------------------------------------------------
  enable_dns_hostnames = true
  enable_dns_support   = true # Set to true for VPC endpoints
  #--------------------------------------------------------------------------------

  #--------------------------------------------------------------------------------
  # RDS
  #--------------------------------------------------------------------------------
  create_database_subnet_group = var.create_database_subnet_group


  #--------------------------------------------------------------------------------
  # SSM
  #--------------------------------------------------------------------------------
  enable_ssm_endpoint = true
  ssm_endpoint_private_dns_enabled = true
  ssm_endpoint_security_group_ids = [
    data.aws_security_group.default.id
  ]

  #--------------------------------------------------------------------------------
  # Secret Manager
  #--------------------------------------------------------------------------------
  enable_secretsmanager_endpoint = true
  secretsmanager_endpoint_private_dns_enabled = true
  secretsmanager_endpoint_security_group_ids = [
    data.aws_security_group.default.id
  ]

  #--------------------------------------------------------------------------------
  # ECR
  # https://aws.amazon.com/blogs/containers/using-vpc-endpoint-policies-to-control-amazon-ecr-access/
  # https://aws.amazon.com/blogs/compute/setting-up-aws-privatelink-for-amazon-ecs-and-amazon-ecr/
  # https://docs.aws.amazon.com/AmazonECR/latest/userguide/vpc-endpoints.html#ecr-vpc-endpoint-considerations
  #
  # [SG]
  # The security group attached to the VPC endpoint must allow incoming connections on port 443 from the private subnet of the VPC.
  #
  # Verify private endpoints with "aws ecr describe-repositories" command.
  #--------------------------------------------------------------------------------
  enable_ecr_api_endpoint = var.enable_ecr_api_endpoint
  ecr_api_endpoint_private_dns_enabled = var.ecr_api_endpoint_private_dns_enabled
  ecr_api_endpoint_security_group_ids = [
    data.aws_security_group.default.id,
#    #local.sg_vpc_endpoint_ecr_id
  ]
  enable_ecr_dkr_endpoint = var.enable_ecr_dkr_endpoint
  ecr_dkr_endpoint_private_dns_enabled = var.ecr_dkr_endpoint_private_dns_enabled
  ecr_dkr_endpoint_security_group_ids = [
    data.aws_security_group.default.id,
#    #local.sg_vpc_endpoint_ecr_id
  ]

  #--------------------------------------------------------------------------------
  # ECS
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/vpc-endpoints.html
  #
  # [S3]
  # https://docs.aws.amazon.com/AmazonECR/latest/userguide/vpc-endpoints.htm
  # To pull private images from Amazon ECR, you must create a gateway endpoint for Amazon S3 for all Amazon ECS tasks.
  #--------------------------------------------------------------------------------
  enable_ecs_endpoint = var.enable_ecs_endpoint
  ecs_endpoint_private_dns_enabled = var.ecs_endpoint_private_dns_enabled
  ecs_endpoint_security_group_ids = [
    data.aws_security_group.default.id,
    #local.sg_vpc_endpoint_ecs_id
  ]
  enable_ecs_agent_endpoint = var.enable_ecs_agent_endpoint
  ecs_agent_endpoint_private_dns_enabled = var.ecs_agent_endpoint_private_dns_enabled
  ecs_agent_endpoint_security_group_ids = [
    data.aws_security_group.default.id,
    #local.sg_vpc_endpoint_ecs_id
  ]
  enable_ecs_telemetry_endpoint = var.enable_ecs_telemetry_endpoint
  ecs_telemetry_endpoint_private_dns_enabled = var.ecs_telemetry_endpoint_private_dns_enabled
  ecs_telemetry_endpoint_security_group_ids = [
    data.aws_security_group.default.id,
    #local.sg_vpc_endpoint_ecs_id
  ]

  #--------------------------------------------------------------------------------
  # Cloudwatch
  #--------------------------------------------------------------------------------
  enable_logs_endpoint = var.enable_logs_endpoint
  logs_endpoint_private_dns_enabled = var.logs_endpoint_private_dns_enabled
  logs_endpoint_security_group_ids = [
    data.aws_security_group.default.id
  ]

  #--------------------------------------------------------------------------------
  # Tag
  #--------------------------------------------------------------------------------
  tags = {
    environment = var.ENV
    project     = var.PROJECT
  }
  database_subnet_tags = {
    resource_type = "subnet"
    subnet_type   = "database"
  }
  private_subnet_tags = {
    resource_type = "subnet"
    subnet_type   = "private"
  }
  intra_subnet_tags = {
    resource_type = "subnet"
    subnet_type   = "intranet"
  }
}

