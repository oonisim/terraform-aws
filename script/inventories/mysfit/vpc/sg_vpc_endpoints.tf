#================================================================================
# SG to allow HTTPS access to the VPC endpoints (VPCE) from those (CIDR, SG) specified.
# TF VPC module then attach the SG to the VPCE when they are created.
# TODO
# Separate Security Group into a module. Configure network access control using security group. For example, limit the access to ECR VPC endpoint only from the SG attached to the ECS EC2 instances.
#================================================================================

#--------------------------------------------------------------------------------
# This is the same with module.vpc.default_security_group... how come?
# See the explanation by Matin Atkins. Module is NOT a node in DAG but just a namespace to group resources.
# Regardless with resources are in a root module or TF module, they are nodes in DAG.
# Module is not an atomic unit in which all the inside resources are created in a atomic manner.
# https://stackoverflow.com/questions/60348519/terraform-why-this-is-not-causing-circular-dependency
#--------------------------------------------------------------------------------
data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group_rule" "vpc_endpoint_ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  # TODO:
  # Should be SG of ECS/EC2
  #cidr_blocks       = ["0.0.0.0/0"]
  cidr_blocks = flatten([
    var.public_subnets,   # TODO: to be removed
    var.private_subnets,
    var.intra_subnets
  ])
  security_group_id = data.aws_security_group.default.id
}

resource "aws_security_group_rule" "vpc_default_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  #cidr_blocks       = ["0.0.0.0/0"]
  cidr_blocks = [
    var.vpc_cidr
  ]
  security_group_id = module.vpc.default_security_group_id
}
