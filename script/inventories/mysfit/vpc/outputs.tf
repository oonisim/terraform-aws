#================================================================================
# Output to be able to verify the resouces created by the module.
#================================================================================
# VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}
output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value = module.vpc.vpc_cidr_block
}
output "default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = module.vpc.default_security_group_id
}

# Subnets
output "intra_subnets" {
  description = "List of IDs of intra subnets"
  value       = [module.vpc.intra_subnets]
}

output "intra_subnets_cidr_blocks" {
  description = "List of cidr_blocks of intra subnets"
  value       = [module.vpc.intra_subnets_cidr_blocks]
}

output "intra_subnet_count" {
  description = "Number of subnets"
  value       = [length(var.intra_subnets)]
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = [module.vpc.private_subnets]
}

output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = [module.vpc.private_subnets_cidr_blocks]
}

output "private_subnet_count" {
  description = "Number of subnets"
  value       = [length(var.private_subnets)]
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = [module.vpc.public_subnets]
}

output "public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of public subnets"
  value       = [module.vpc.public_subnets_cidr_blocks]
}

output "public_subnet_count" {
  description = "Number of subnets"
  value       = [length(var.public_subnets)]
}

output "database_subnets" {
  description = "List of IDs of database subnets"
  value       = [module.vpc.database_subnets]
}

output "database_subnets_cidr_blocks" {
  description = "List of cidr_blocks of database subnets"
  value       = [module.vpc.database_subnets_cidr_blocks]
}

output "database_subnet_count" {
  description = "Number of subnets"
  value       = [length(var.database_subnets)]
}

output "elasticache_subnets" {
  description = "List of IDs of elasticache subnets"
  value       = [module.vpc.elasticache_subnets]
}

output "elasticache_subnets_cidr_blocks" {
  description = "List of cidr_blocks of elasticache subnets"
  value       = [module.vpc.elasticache_subnets_cidr_blocks]
}

output "elasticache_subnet_count" {
  description = "Number of subnets"
  value       = [length(var.elasticache_subnets)]
}

output "redshift_subnets" {
  description = "List of IDs of redshift subnets"
  value       = [module.vpc.redshift_subnets]
}

output "redshift_subnets_cidr_blocks" {
  description = "List of cidr_blocks of redshift subnets"
  value       = [module.vpc.redshift_subnets_cidr_blocks]
}

output "redshift_subnet_count" {
  description = "Number of subnets"
  value       = [length(var.redshift_subnets)]
}

# NAT gateways
output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = [module.vpc.nat_public_ips]
}

# Route tables
output "public_route_table_ids" {
  description = "List of IDs of public route tables"
  value       = [module.vpc.public_route_table_ids]
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = [module.vpc.private_route_table_ids]
}

output "intra_route_table_ids" {
  description = "List of IDs of intra route tables"
  value       = [module.vpc.intra_route_table_ids]
}

# VPC Endpoints
output "vpc_endpoint_dynamodb_id" {
  description = "The ID of VPC endpoint for DynamoDB"
  value       = module.vpc.vpc_endpoint_dynamodb_id
}

output "vpc_endpoint_dynamodb_pl_id" {
  description = "The prefix list for the DynamoDB VPC endpoint."
  value       = module.vpc.vpc_endpoint_dynamodb_pl_id
}

output "vpc_endpoint_s3_id" {
  description = "The ID of VPC endpoint for S3"
  value       = module.vpc.vpc_endpoint_s3_id
}

output "vpc_endpoint_s3_pl_id" {
  description = "The prefix list for the S3 VPC endpoint."
  value       = module.vpc.vpc_endpoint_s3_pl_id
}

output "vpc_sg_default_id" {
  value = module.vpc.default_security_group_id
}
