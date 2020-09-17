# TODO: Incorporate multiple ELB and ELB types.
# ECS service can have multiple ELB and target groups. In a same ECS service, a ECS task may have
# multiple micro services that use different ELB (ALB or ELB) respectively.
# microservice_XYZ uses ALB target group, and microservice_STU uses NLB target group.
locals {
  backend_key_lb  = data.terraform_remote_state.common.outputs.elb_type_for_microservice_XYZ == data.terraform_remote_state.common.outputs.ELB_TYPE_ALB ? "alb.tfstate" : "nlb.tfstate"
}

output "backend_key_lb" {
  value = local.backend_key_lb
}