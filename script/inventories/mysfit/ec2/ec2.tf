#--------------------------------------------------------------------------------
# EC2 keypair
#--------------------------------------------------------------------------------
resource "aws_key_pair" "this" {
  key_name   = "${var.PROJECT}-${var.ENV}-keypair-for-ecs-cluster-${local.ecs_cluster_name}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDwGqmwLfBJ1MaFJy5cEoCFAAYxmTuJJc8VrAe26hSa55Mj7kofCfx/iPquRF2fXzDrPiRc+dK1n79UO9JREj4DFOX79bpBgvjc6Q9ljph0vsVPrk7jdgrpupRemvfPVNNgwzi5EcLfEMjmMH8Yl0yPA5sI0hNKJxKE9tqZqVNP+eiCstU0lnwVJsVlLWZ7rhxotbw/Dzt58+GSfA2TthfgN/EdNlwesRIqkreoUhNO/nZzARNpOv9rm/lH0DZpdLF8skTJINHHVJOe93DQbOvoJPoybsJ5y27k4I8POz5oi9d48rkHyFgAG2952ADWr/zOOuoZChB36uwBOhSu9BWxcznkor0QIBqHqDV4o9rDPmPtZRLbhfreKY0B4uP7x/eRwsiVZ8DZDJVsQue0Au+Gx09GRsu1GnIULm5Lp387tHLjQZQTZA6R4LTUdR2uEJ2GtGc+6rnEkc4Awgx40mE1SYoYqwO3D4b0SCbhxskp7vxl8iD1LV5zkvJG9+XfNgc= userm4p@WS226440"
}

#--------------------------------------------------------------------------------
# ECS EC2 instance
#--------------------------------------------------------------------------------
resource "aws_instance" "ecs" {
  count = var.number_of_ec2_instances_for_ecs_cluster
  ami           = "${local.ami_microservice_XYZ_id}"
  instance_type = "t2.micro"
  key_name = aws_key_pair.this.key_name

  # NOTE: If you are creating Instances in a VPC, use vpc_security_group_ids instead.
  # security_groups attribute is for EC2-Classic and default VPC only.

  subnet_id = local.subnet_ecs_cluster_asg_ids[0]
  /*
  vpc_security_group_ids = flatten([
    aws_security_group.lc_ecs_cluster_debug[*].id,
    aws_security_group.lc_ecs_cluster_service_ABC.id,
    aws_security_group.lc_ecs_cluster_ssh.id
  ])
  */
  vpc_security_group_ids = local.sg_ec2_ecs_service_ids

  iam_instance_profile  = "${local.ec2_ecs_service_instance_profile_name}"

  user_data             = "${local.user_data}"

  root_block_device {
    volume_type = var.ec2_ecs_service_volume_type
    volume_size = var.ec2_ecs_service_volume_size
    delete_on_termination = true
  }

  tags ={
    Project = var.PROJECT
    Environment = var.ENV
  }
}