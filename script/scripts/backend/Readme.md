# Manage the terraform backend S3 bucket

### create.sh
Create the terraform S3 backend bucket. 

Specify the backend directory in the terraform inventory (environment) directory e.g. terraform/inventories/ecs-monolish/backend.

Specify the PREFIX, PROJECT, ENV in the terraform/inventories/ecs-monolish/backend/terraform.tfvars.

### destroy.sh
Delete the backend bucket after the terraform project/env is completely deleted.