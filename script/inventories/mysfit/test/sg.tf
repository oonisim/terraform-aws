resource "aws_security_group" "ec2_bastion_ssh" {
  name = "${var.PROJECT}_${var.ENV}_sg_bastion_ssh"
  vpc_id = local.vpc_ecs_cluster_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  lifecycle {
    create_before_destroy = true
  }
}

output "aws_security_group_ec2_bastion_ssh_id" {
  value = aws_security_group.ec2_bastion_ssh.id
}
output "aws_security_group_ec2_bastion_ssh_ingress" {
  value = aws_security_group.ec2_bastion_ssh.ingress
}