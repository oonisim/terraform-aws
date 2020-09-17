#--------------------------------------------------------------------------------
# [Service Role]
# IAM role for ECS to register instances to ELB (target group).
# - EC2 permissions
# - ELB permission
#
# Trouble shooting
# See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/security_iam_troubleshoot.html
#
# [Clarifiation]
# If it is required when not using Fargate
#--------------------------------------------------------------------------------
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service_IAM_role.html
#--------------------------------------------------------------------------------
resource "aws_iam_role" "ecs_service" {
  name                = "${var.PROJECT}_${var.ENV}_ecs_service_${var.ecs_service_name}"
  assume_role_policy  = data.aws_iam_policy_document.allow_assume_ecs.json
  path                = "/"
}

data "aws_iam_policy_document" "allow_assume_ecs" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = [
        "ecs.amazonaws.com"
      ]
    }
  }
}

#--------------------------------------------------------------------------------
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_managed_policies.html
#--------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "ecs_service" {
  role       = aws_iam_role.ecs_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

#--------------------------------------------------------------------------------
# ECS service linked role
# Prior to the introduction of a service-linked role for ECS, you were required to create
# an IAM role for ECS services which granted ECS the permission it needed.
# This role is no longer required, however it is available if needed.
# For more information, see Legacy IAM Roles for Amazon ECS.
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using-service-linked-roles.html
#--------------------------------------------------------------------------------
