#--------------------------------------------------------------------------------
# EC2 keypair
#--------------------------------------------------------------------------------
resource "aws_key_pair" "this" {
  key_name   = var.keypair_name
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDwGqmwLfBJ1MaFJy5cEoCFAAYxmTuJJc8VrAe26hSa55Mj7kofCfx/iPquRF2fXzDrPiRc+dK1n79UO9JREj4DFOX79bpBgvjc6Q9ljph0vsVPrk7jdgrpupRemvfPVNNgwzi5EcLfEMjmMH8Yl0yPA5sI0hNKJxKE9tqZqVNP+eiCstU0lnwVJsVlLWZ7rhxotbw/Dzt58+GSfA2TthfgN/EdNlwesRIqkreoUhNO/nZzARNpOv9rm/lH0DZpdLF8skTJINHHVJOe93DQbOvoJPoybsJ5y27k4I8POz5oi9d48rkHyFgAG2952ADWr/zOOuoZChB36uwBOhSu9BWxcznkor0QIBqHqDV4o9rDPmPtZRLbhfreKY0B4uP7x/eRwsiVZ8DZDJVsQue0Au+Gx09GRsu1GnIULm5Lp387tHLjQZQTZA6R4LTUdR2uEJ2GtGc+6rnEkc4Awgx40mE1SYoYqwO3D4b0SCbhxskp7vxl8iD1LV5zkvJG9+XfNgc= userm4p@WS226440"
}

#--------------------------------------------------------------------------------
# The AMI can be region specific. Verify the available AMI in the region.
#--------------------------------------------------------------------------------
data "aws_ami" "amzn2" {
  most_recent = true
  filter {
    name   = "name"
    values = [
      var.ec2_ami_bastion_name_filter
    ]
  }

  filter {
    name   = "virtualization-type"
    values = [
      "hvm"]
  }
  owners = [
    "amazon"]
}

#--------------------------------------------------------------------------------
# EC2 instanct to run the connectivity tests to ECS EC2 instances.
#--------------------------------------------------------------------------------
resource "aws_instance" "bastion" {
  ami           = "${data.aws_ami.amzn2.id}"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.this.key_name

  subnet_id = local.ecs_cluster_public_subnet_ids[0]

  vpc_security_group_ids = [
    aws_security_group.ec2_bastion_ssh.id
  ]

  #--------------------------------------------------------------------------------
  # TF provisioner
  # https://www.terraform.io/docs/provisioners/index.html
  # https://learn.hashicorp.com/terraform/getting-started/provision
  #--------------------------------------------------------------------------------
  provisioner "local-exec" {
    #--------------------------------------------------------------------------------
    # nc verbose output -v option is stderr.
    #--------------------------------------------------------------------------------
    command    = <<EOF
echo ${self.public_ip} | tee bastion_ip_address.log
nc -zv ${self.public_ip} 22 2>&1 | tee "bastion_nc_result.log"
EOF
    on_failure = "fail"
  }


  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }

    inline     = [
      "sudo amazon-linux-extras enable epel",
      "sudo yum -y install nmap-ncat telnet",
      "nc -zv ${local.ecs_ec2_instance_private_ips[0]} 22"
    ]
    on_failure = "fail"
  }

  tags = {
    Project     = var.PROJECT
    Environment = var.ENV
    Name        = "ecs-test-bastion-instance"
  }
}

output "aws_instance_bastion_public_dns" {
  value = aws_instance.bastion.public_dns
}
output "aws_instance_bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}
output "aws_instance_bastion_id" {
  value = aws_instance.bastion.id
}
output "aws_instance_bastion_security_groups" {
  value = aws_instance.bastion.security_groups
}