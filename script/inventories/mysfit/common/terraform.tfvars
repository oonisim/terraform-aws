#================================================================================
# ECS Cluster
#================================================================================
ecs_cluster_name = "myecs"

#--------------------------------------------------------------------------------
# ECS Cluster scaling
# DO not confuse Cluster (EC2) scaling with Service (container) scaling
#--------------------------------------------------------------------------------

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# Not enableing the ASG from TF:
# Due to AWS ECS bug, cannot delete Capacity Provider once created. Hence causing the error
# when re-running terrafor apply as terraform destroy cannot delete it.
# [Error]
# error creating capacity provider: ClientException: The specified capacity provider already exists.
# To change the configuration of an existing capacity provider, update the capacity provider.
#
# [ECS] Add the ability to delete an ASG capacity provider. #632
# https://github.com/aws/containers-roadmap/issues/632
#
# There is no aws_ecs_capacity_provider datasource as of now.
# -> Raised https://github.com/terraform-providers/terraform-provider-aws/issues/12301
#
# Once fell in the situation, disable the capacity provider, and add the created one
# manually.
# https://stackoverflow.com/questions/60056801/aws-ecs-capacity-provider-using-terraform/60575634#60575634
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
enable_ecs_cluster_auto_scaling = false
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
ecs_cluster_autoscaling_min_size = 1
ecs_cluster_autoscaling_max_size = 3
ecs_cluster_autoscaling_target_capacity = 2
ecs_cluster_autoscaling_min_step_size = 1
ecs_cluster_autoscaling_max_step_size = 1

#--------------------------------------------------------------------------------
# ECS services
#--------------------------------------------------------------------------------
ecs_service_ABC_name = "ABC"

#--------------------------------------------------------------------------------
# ECS service scaling
#--------------------------------------------------------------------------------
ecs_task_ABC_desired_count = 2  # WARNING! This paramter is for creation time only

#--------------------------------------------------------------------------------
# Microservices of ECS Service
#--------------------------------------------------------------------------------
microservice_XYZ_name = "mysfits"

#--------------------------------------------------------------------------------
# ELB
#--------------------------------------------------------------------------------
client_port_for_microservice_XYZ = 80

# CIDR blocks to specify the client IP address range from where the access is expected.
# To limit which IP can access to the service, set the CIDR blocks here.
ingress_cidr_blocks_at_elb_for_service_ABC = [
  "0.0.0.0/0"
]

#--------------------------------------------------------------------------------
# SG for ECS EC2
#--------------------------------------------------------------------------------
# TODO: Disable debug mode!!!
ENABLE_ECS_EC2_CONNECTION_DEBUG = false

#--------------------------------------------------------------------------------
# ECS Task
#--------------------------------------------------------------------------------
ecs_task_ABC_network_mode = "bridge"
ecs_service_ABC_healthcheck_grece_period = 180

#--------------------------------------------------------------------------------
# ECS microservices
#--------------------------------------------------------------------------------
protocol_for_microservice_XYZ = "TCP"     # This will force NLB
#protocol_for_microservice_XYZ = "HTTP"   # This will force ALB

#ec2_host_port_for_microservice_XYZ = 8080  # Set 0 for dynamic port mapping
ec2_host_port_for_microservice_XYZ = 0  # Set 0 for dynamic port mapping

#docker_container_port_for_microservice_XYZ = 3000
docker_container_port_for_microservice_XYZ = 8080

#--------------------------------------------------------------------------------
# Service Health check protocol/port
# TODO: Verify if ECS will update target group healthcheck for dynamic port mapping
# If it does, then the healthcheck port is the same with ec2_host_port_for_microservice_XYZ
#--------------------------------------------------------------------------------
/*
Set ec2_host_port_for_microservice_XYZ and  as the
output values of these variables.

ec2_healthcheck_protocol_for_microservice_XYZ =
ec2_healthcheck_port_for_microservice_XYZ =
*/

