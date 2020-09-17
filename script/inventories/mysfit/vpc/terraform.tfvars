vpc_cidr = "10.5.0.0/20"

public_subnets = ["10.5.0.0/24", "10.5.1.0/24", "10.5.2.0/24"]
private_subnets = ["10.5.3.0/24", "10.5.4.0/24", "10.5.5.0/24"]
intra_subnets = ["10.5.6.0/24", "10.5.7.0/24", "10.5.8.0/24"]

# RDS Subnet Group
create_database_subnet_group = false
# database_subnets = ["10.5.9.0/24", "10.5.10.0/24", "10.5.11.0/24"]
redshift_subnets = []
elasticache_subnets = []

enable_ssh  = true


#================================================================================
# NAT
# Cost just having NAT without using. Consider VPC endpoints to contain traffic within VPC.
#================================================================================
enable_nat_gateway = false
one_nat_gateway_per_az = false

#================================================================================
# VPC Gateway Endpoint
#================================================================================
#--------------------------------------------------------------------------------
# S3
# Requred for ECR to save images
#--------------------------------------------------------------------------------
enable_s3_endpoint = true

#--------------------------------------------------------------------------------
# Dynamodb
#--------------------------------------------------------------------------------
enable_dynamodb_endpoint = true
create_mysql  = false

#================================================================================
# VPC Interface Endpoint
#================================================================================
#--------------------------------------------------------------------------------
# SSM
#--------------------------------------------------------------------------------
enable_ssm_endpoint = false
ssm_endpoint_private_dns_enabled = false

#--------------------------------------------------------------------------------
# Secret Manager
#--------------------------------------------------------------------------------
enable_secretsmanager_endpoint = false
secretsmanager_endpoint_private_dns_enabled = false

#--------------------------------------------------------------------------------
# ECR
# https://aws.amazon.com/blogs/containers/using-vpc-endpoint-policies-to-control-amazon-ecr-access/
#--------------------------------------------------------------------------------
enable_ecr_api_endpoint = true
ecr_api_endpoint_private_dns_enabled = true
enable_ecr_dkr_endpoint = true
ecr_dkr_endpoint_private_dns_enabled = true

#--------------------------------------------------------------------------------
# ECS
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/vpc-endpoints.html
#--------------------------------------------------------------------------------
enable_ecs_endpoint = true
ecs_endpoint_private_dns_enabled = true
enable_ecs_agent_endpoint = true
ecs_agent_endpoint_private_dns_enabled = true
enable_ecs_telemetry_endpoint = true
ecs_telemetry_endpoint_private_dns_enabled = true

#--------------------------------------------------------------------------------
# Cloudwatch
#--------------------------------------------------------------------------------
enable_logs_endpoint = true
logs_endpoint_private_dns_enabled = true
