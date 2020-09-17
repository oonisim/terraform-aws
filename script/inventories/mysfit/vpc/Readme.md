# Network module

Create VPC, subnets, Network ACL for the subnets.

Modules in Terraform registry utilized:
* [VPC module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/)

### Trouble shooting

- Verify the NACL rules. 
- Remove the NACL to verify if NACLs are the causes.
- Create a EC2 instances within subnets and test the connectivity with SSH.
- Create a CloudWatch VCP flow logs to verify denied connections.

