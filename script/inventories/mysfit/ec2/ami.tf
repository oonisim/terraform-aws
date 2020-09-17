
locals {
  ami_microservice_XYZ_id = "${data.aws_ami.myecs_service.id}"
}

#--------------------------------------------------------------------------------
# EC2 AMI for ECS
#--------------------------------------------------------------------------------
data "aws_ami" "myecs_service" {
  most_recent = true
  owners = ["amazon"]

  # Find ECS optimized AMI image
  filter {
    name   = "name"
    #values = ["amzn2-ami-ecs-hvm*"]
    values = ["amzn*ecs-optimized*"]
  }
  /*
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  */
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}