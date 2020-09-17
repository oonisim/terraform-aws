#--------------------------------------------------------------------------------
# ECS EC2 instance information
#--------------------------------------------------------------------------------
locals {
  ecs_ec2_instance_ids         = data.terraform_remote_state.ec2.outputs.ecs_ec2_instance_ids
  ecs_ec2_instance_private_ips = data.terraform_remote_state.ec2.outputs.ecs_ec2_instance_private_ips
}
output "ecs_ec2_instance_ids" {
  value = local.ecs_ec2_instance_ids
}
output "ecs_ec2_instance_private_ips" {
  value = local.ecs_ec2_instance_private_ips
}

#--------------------------------------------------------------------------------
# Test bastion EC2 SSH connection
#
# If this does not work, check the isntance status and SG.
#--------------------------------------------------------------------------------
resource "null_resource" "test_ssh_to_bastion" {
  provisioner "local-exec" {
    command = <<EOF
echo '--------------------------------------------------------------------------------',
echo 'Test SSH connectivity to the bastion host...',
echo '--------------------------------------------------------------------------------',
aws ec2 wait instance-running --instance-ids "${aws_instance.bastion.id}" --region "${var.REGION}"
nc -zv "${aws_instance.bastion.public_ip}" 22
EOF
  }
  triggers = {
    ts = timestamp()
  }
  depends_on = [
    aws_instance.bastion
  ]
}

resource "null_resource" "setup_connection_to_ecs_ec2_from_bastion" {
  # https://www.terraform.io/docs/provisioners/connection.html#connecting-through-a-bastion-host-with-ssh

  #--------------------------------------------------------------------------------
  # Configure bastion host
  #--------------------------------------------------------------------------------
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/id_rsa")
      host        = aws_instance.bastion.public_dns
    }

    inline = [
      "echo '--------------------------------------------------------------------------------'",
      "echo 'Installing packages...'",
      "echo '--------------------------------------------------------------------------------'",
      "sudo amazon-linux-extras enable epel",
      "sudo yum -y install nmap-ncat",
    ]

    on_failure = "continue"
  }
  triggers = {
    ts = timestamp()
  }
  depends_on = [
    null_resource.test_ssh_to_bastion
  ]

}

#--------------------------------------------------------------------------------
# Test TCP connectivity to the ECS/EC2 host port from the EC2 bastion host
# SSH remote-exect -> SSH server on EC2 bastion -> ECS/EC2 host port
#
#
# [ECS/ECS SG]
# - check SG ingress of the ECS/EC2
# - Check outbound internet connectivity to be able to reach AWS service public endpoints.
#
# [ECS/EC2/ECS agent]
# - Check cloud init log for any errors.
# - Check ECS agent log for errors.
# - Check ECS agent servie status "sudo service ecs-agent status"
#
# [ECS/EC2/Docker]
# - Check docker container process running "docker ps"
# - Check docker container port mapping to EC2 host port.
# - Test connectivity to the host port.
# - Login to docker conntainer running the microservice to verify internal process running and responding.
#--------------------------------------------------------------------------------
resource "null_resource" "test_connection_to_ecs_ec2_from_bastion" {
  # https://www.terraform.io/docs/provisioners/connection.html#connecting-through-a-bastion-host-with-ssh

  #--------------------------------------------------------------------------------
  # Test connectivity from bastion to the ECS EC2
  #--------------------------------------------------------------------------------
  provisioner "remote-exec" {
    connection {
      type         = "ssh"
      user         = "ec2-user"
      private_key  = file("~/.ssh/id_rsa")
      host         = aws_instance.bastion.public_dns
    }

    inline = [
      "echo '--------------------------------------------------------------------------------'",
      "echo 'Testing connectivity to the SSH and microservie XYZ host_port on ECS EC2 ...'",
      "echo '--------------------------------------------------------------------------------'",
      "aws ec2 wait instance-running --instance-ids ${local.ecs_ec2_instance_ids[0]} --region ${var.REGION}",
      "nc -zv ${local.ecs_ec2_instance_private_ips[0]} 22",

      #--------------------------------------------------------------------------------
      # We do not know the dynamic port.
      # TODO: Retrieve the EC2 host ports of microservics from ECS tasks using AWS CLI.
      #--------------------------------------------------------------------------------
      #"nc -zv ${local.ecs_ec2_instance_private_ips[0]} ${local.ec2_host_port_for_microservice_XYZ}"
    ]

    #on_failure = "fail"
    on_failure = "continue"
  }

  triggers = {
    ts = timestamp()
  }

  depends_on = [
    null_resource.setup_connection_to_ecs_ec2_from_bastion
  ]

}


#--------------------------------------------------------------------------------
# Test ECS agent
#--------------------------------------------------------------------------------
resource "null_resource" "test_ecs_agent_on_ecs_ec2" {
  # https://www.terraform.io/docs/provisioners/connection.html#connecting-through-a-bastion-host-with-ssh

  connection {
    type         = "ssh"
    user         = "ec2-user"
    private_key  = file("~/.ssh/id_rsa")
    host         = local.ecs_ec2_instance_private_ips[0]
    bastion_host = aws_instance.bastion.public_dns
  }

  #--------------------------------------------------------------------------------
  # Test connectivity from bastion to the ECS EC2
  #--------------------------------------------------------------------------------
  provisioner "remote-exec" {

    #--------------------------------------------------------------------------------
    # TODO: Verify if the AMI is AMZON 1 or AMZON 2.
    # For AMZN 1, use "sudo status ecs", for AMZN 2, use sudo systemcl ecs status
    # https://aws.amazon.com/premiumsupport/knowledge-center/ecs-agent-disconnected/
    # https://aws.amazon.com/premiumsupport/knowledge-center/ecs-agent-disconnected-linux2-ami/
    # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/troubleshooting.html
    #--------------------------------------------------------------------------------
#       "sudo status ecs | grep -q 'ecs start/running' || echo ECS Agent is not running && exit -1",

    inline = [
      "echo '--------------------------------------------------------------------------------'",
      "echo 'Docker status and processes ...'",
      "echo '--------------------------------------------------------------------------------'",
      "sudo service docker status",
      "sudo docker ps",
      "echo '--------------------------------------------------------------------------------'",
      "echo 'Docker log ...'",
      "echo '--------------------------------------------------------------------------------'",
      "sudo cat /var/log/docker",
      "echo '--------------------------------------------------------------------------------'",
      "echo 'ECS agent status ...'",
      "echo '--------------------------------------------------------------------------------'",
      "sudo status ecs",
      "echo '--------------------------------------------------------------------------------'",
      "echo 'ECS agent init log ...'",
      "echo '--------------------------------------------------------------------------------'",
      "sudo cat /var/log/ecs/ecs-init.log",
    ]

    on_failure = "continue"
  }

  triggers = {
    ts = timestamp()
  }

  depends_on = [
    null_resource.test_connection_to_ecs_ec2_from_bastion
  ]
}

#--------------------------------------------------------------------------------
# Test ELB connection to the microservice
#--------------------------------------------------------------------------------
resource "null_resource" "test_elb_target" {
  provisioner "local-exec" {
    command = <<EOF
echo '--------------------------------------------------------------------------------'
echo "Test ELB connectivity ${local.ec2_host_port_for_microservice_XYZ}"
echo '--------------------------------------------------------------------------------'
nc -zv "${local.elb_dns_name}" ${local.client_port_for_microservice_XYZ}
echo '--------------------------------------------------------------------------------'
echo "Acquiring the HTTP content"
echo '--------------------------------------------------------------------------------'
curl -vL "${local.elb_dns_name}:${local.client_port_for_microservice_XYZ}"
EOF
  }
  triggers = {
    ts = timestamp()
  }
  depends_on = [
    null_resource.test_ecs_agent_on_ecs_ec2
  ]
}
