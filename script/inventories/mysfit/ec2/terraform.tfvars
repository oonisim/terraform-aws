number_of_ec2_instances_for_ecs_cluster = 2

#--------------------------------------------------------------------------------
# launch configuration
#--------------------------------------------------------------------------------
lc_name = "service"
ec2_user_for_ecs_cluster = "ec2-user"
ec2_ecs_service_instance_type = "t2.micro"
ec2_ecs_service_volume_type = "standard"

#--------------------------------------------------------------------------------
# Launching a new EC2 instance.
# Status Reason: Volume of size 20GB is smaller than snapshot expect size >= 30GB.
# The root block device size of an AMI restrics the minimum volume size.
# [Identify the root device size of an AMI]
#aws ec2 describe-images \
#--owners amazon \
#--filters \
#'Name=name,Values=amzn2-ami-ecs-hvm*' \
#'Name=architecture,Values=x86_64' \
#'Name=virtualization-type,Values=hvm' \
#'Name=state,Values=available' \
#--output json \
#| jq -r '.Images | sort_by(.CreationDate)| last(.[]).BlockDeviceMappings[].Ebs.VolumeSize'
#--------------------------------------------------------------------------------
#ec2_ecs_service_volume_size = 20
ec2_ecs_service_volume_size = 30
#--------------------------------------------------------------------------------
ec2_ecs_service_keypair_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDwGqmwLfBJ1MaFJy5cEoCFAAYxmTuJJc8VrAe26hSa55Mj7kofCfx/iPquRF2fXzDrPiRc+dK1n79UO9JREj4DFOX79bpBgvjc6Q9ljph0vsVPrk7jdgrpupRemvfPVNNgwzi5EcLfEMjmMH8Yl0yPA5sI0hNKJxKE9tqZqVNP+eiCstU0lnwVJsVlLWZ7rhxotbw/Dzt58+GSfA2TthfgN/EdNlwesRIqkreoUhNO/nZzARNpOv9rm/lH0DZpdLF8skTJINHHVJOe93DQbOvoJPoybsJ5y27k4I8POz5oi9d48rkHyFgAG2952ADWr/zOOuoZChB36uwBOhSu9BWxcznkor0QIBqHqDV4o9rDPmPtZRLbhfreKY0B4uP7x/eRwsiVZ8DZDJVsQue0Au+Gx09GRsu1GnIULm5Lp387tHLjQZQTZA6R4LTUdR2uEJ2GtGc+6rnEkc4Awgx40mE1SYoYqwO3D4b0SCbhxskp7vxl8iD1LV5zkvJG9+XfNgc= userm4p@WS226440"


#--------------------------------------------------------------------------------
# EC2 userdata variables
# Docker registry host depends on the environment.
# [ECR]
# https://docs.aws.amazon.com/AmazonECR/latest/userguide/Registries.html
# The URL for your default registry is https://aws_account_id.dkr.ecr.region.amazonaws.com.
#--------------------------------------------------------------------------------
#docker_repository_host = "TBD"
#docker_repository_port = 8081

#--------------------------------------------------------------------------------
# LC
# TODO: Security Gateway ingress from/to port separation and incorporate dynamic port mapping.
# For the ephemeral host-port, specify the possible port range.
# For non dymamic port mapping, specify multiple ingress rules for possible host ports.
# There can be multiple container_definitions (and multiple task defintions), so all potential
# ports need to be passed as a list.
#--------------------------------------------------------------------------------
/*
ec2_microservice_XYZ_protocol = "-1"
ec2_microservice_XYZ_host_port = 0
ec2_sg_microservice_XYZ_external_client_cidr_blocks = ["0.0.0.0/0"]
*/
lc_ecs_cluster_ssh_port = 22
lc_ecs_cluster_ssh_protocol = "tcp"

#--------------------------------------------------------------------------------
# EC2 Health check protocol/port
# We do not know the service process host-port e.g. dynamic port mapping.
# There could be multiple services and we may not know which one to use for service health check.
# For now, just use SSH port believing SSH server is always available.
#--------------------------------------------------------------------------------
/*
ec2_microservice_XYZ_healthcheck_protocol = "tcp"
ec2_microservice_XYZ_healthcheck_host_port = 22
*/