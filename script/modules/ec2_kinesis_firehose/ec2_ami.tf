locals {
  ami_this_id = "${data.aws_ami.this.id}"
}

#--------------------------------------------------------------------------------
# EC2 AMI for ECS
#--------------------------------------------------------------------------------
data "aws_ami" "this" {
  most_recent = true
  owners = ["amazon"]

  # Find ECS optimized AMI image
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}