#--------------------------------------------------------------------------------
# AWS data sources in the defined region
# Availability zones can differ depending on the region, hence retrieve facts.
# DO NOT hard-code e.g. AZ-A as there may not be 'AZ-A' in a region.
#--------------------------------------------------------------------------------
# The available AZs in the region defined in the provider will be retrieved into
# "aws_availability_zones" data source object.
data "aws_availability_zones" "all" {
}

data "aws_region" "current" {
}

