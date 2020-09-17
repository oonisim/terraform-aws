#================================================================================
# Terminlogies]
# There can be multiple micro service XYZ instances in a cluster for scaling.
# To be simple, assume there is only one docker container instance providing the service XYZ in one EC2 instance.
#
# [microservice_XYZ]:
# A docker container instance of a micro service XYZ.
# ECS task can have multiple docker containers, but a specififc micro service is a specific docker container.
#
# [Ephemeral ports]
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#container_definition_portmappings
# Port range 49153–65535 In general, ports below 32768 are outside of the ephemeral port range.
# From which an ephemeral port for a EC2 host port is assigned when dynamic port mapping is used.
#================================================================================

#================================================================================
# Constants
#================================================================================
variable "ELB_TYPES" {
  description = "Possible ELB type values"
  default = ["network", "application"]
  type = list(string)
}
variable "ELB_TYPE_ALB" {
  description = "ALB type value"
  default = "application"
  type = string
}
variable "ELB_TYPE_NLB" {
  description = "NLB type value"
  default = "network"
  type = string
}
variable "NLB_PROTOCOLS" {
  description = "Possible NLB protocol values"
  default = ["TCP", "UDP", "TCP_UDP"]
  type = list(string)
}
variable "ALB_PROTOCOLS" {
  description = "Possible ALB protocol values"
  default = ["HTTPS", "HTTP"]
  type = list(string)
}

#--------------------------------------------------------------------------------
# https://aws.amazon.com/premiumsupport/knowledge-center/dynamic-port-mapping-ecs/
# the registered targets for the following ephemeral port ranges: 49153–65535 and 32768–61000
# (should be 32768-65535)
#--------------------------------------------------------------------------------
variable "DOCKER_EPHEMERAL_FROM_PORT" {
  description = "Docker ephemeral port ranges lower bound"
  default = 32768
}
variable "DOCKER_EPHEMERAL_TO_PORT" {
  description = "Docker ephemeral port ranges upper bound"
  default = 65535
}

#================================================================================
# ECS Cluster
# [Cyclic Dependency]
# ECS Agent on EC2 needs to know the ECS cluster name to join.
# ECS cluster needs to know ASG to setup its capacity provide.
#
# Provide the ECS cluster name from global parameters.
# Currently the modules prepends PROJECT-ENV to the name.
#================================================================================
variable "ecs_cluster_name" {
  description = "Name of the ECS cluster to which the EC2 instances of the ECS services to join"
}

#--------------------------------------------------------------------------------
# ECS Cluster (EC2) auto-scaling
# https://www.terraform.io/docs/providers/aws/r/ecs_capacity_provider.html
#--------------------------------------------------------------------------------
variable "enable_ecs_cluster_auto_scaling" {
  description = "Flag to enable ECS cluster auto-scaling"
  type = bool
  default = false
}
variable "ecs_cluster_autoscaling_min_size" {
  type = number
  default = 1
}
variable "ecs_cluster_autoscaling_max_size" {
  type = number
}
variable "ecs_cluster_autoscaling_target_capacity" {
  description = "ECS cluster auto-scaling target capacity (NOT service auto-scaling which is for docker container instances)"
  type = number
}
variable "ecs_cluster_autoscaling_min_step_size" {
  description = "ECS cluster auto-scaling step adjustment min"
  type = number
}
variable "ecs_cluster_autoscaling_max_step_size" {
  description = "ECS cluster auto-scaling step adjustment max"
  type = number
}

#================================================================================
# ECS Service
# TODO: Documentation on "ECS Service" vs "Microservice".
# ECS Service has one ECS Task which may have multiple docker containers, each of
# which providing a **service**.
#
# Need to have a clear definition of what a "Service" is.
# "Service" here is a responsibility to provide a speficic function with a specific I/F which is a Port.
# Hence
# 1. ECS Service has 1 to N relationship to Microservice.
# 2. Each Microservice is a Docker Container that provide a specific function via one specific port.
#
#================================================================================
variable "ecs_service_ABC_name" {
  description = "Name of the ECS Serice which may have multiple Microservices"
}

#--------------------------------------------------------------------------------
# CIDR blocks from which to allow inbound connections from the external consumers.
#
# For now, one CIDR cover all microservices in ECS service ABC, although CIDR blocks
# to accept may differ depending on the micro-service, such as micro-service X
# is administration hence only from corporate network public IP.
#--------------------------------------------------------------------------------
variable "ingress_cidr_blocks_at_elb_for_service_ABC" {
  description = "ALB Security Group ingress CIDR blocks from which to accept external incoming connection to microservice XYZ"
  type = list(string)
}

#================================================================================
# ECS task
# ECS Service and ECS Task is one to one at runtime level.
# (ECS service can have multiple versions of the task definition at definitil level)
#
# ECS Task defines multiple container definitions and applies a single task definition
# to all the containers, such as Docker network mode which restricts the ELB target type.
#================================================================================
#--------------------------------------------------------------------------------
# ECS Task level "network_mode" applies to all the containers.
#--------------------------------------------------------------------------------
variable "ecs_task_ABC_network_mode" {
  #--------------------------------------------------------------------------------
  # [ECS Task Definition Parameters - Network Mode]
  # The Docker networking mode to use for the containers in the task. The valid values are none, bridge, awsvpc, and host.
  # - bridge, the task use Docker's built-in virtual network which runs inside each container instance.
  # - host, the task bypasses Docker's built-in virtual network and maps container ports directly to the EC2 ENI.
  #         In this mode, you can't run multiple instantiations of the same task
  # - awsvpc, the task is allocated an dedicated ENI (EC2 restccition depending on the EC2 type)
  #           See https://aws.amazon.com/about-aws/whats-new/2019/06/Amazon-ECS-Improves-ENI-Density-Limits-for-awsvpc-Networking-Mode/
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#network_mode
  #
  # [Docker run reference - Network settings]
  # - none	No networking in the container.
  # - bridge (default)	Connect the container to the bridge via veth interfaces.
  # - host	Use the host's network stack inside the container.
  # https://docs.docker.com/engine/reference/run/#/network-settings#network-settings
  #--------------------------------------------------------------------------------
  description = "Network Mode for the ECS task of ECS service"
  default = "bridge"
  type = string
}
variable "ecs_task_ABC_desired_count" {
  #--------------------------------------------------------------------------------
  # WARNING! This paramter is for creation time only.
  # So as to ignore any changes to that count caused externally (e.g. Application Autoscaling).
  # This will allow external changes without Terraform plan difference.
  # https://www.terraform.io/docs/providers/aws/r/ecs_service.html#ignoring-changes-to-desired-count
  #--------------------------------------------------------------------------------

  #--------------------------------------------------------------------------------
  ## The number of instantiations of the specified task definition (=docker image) running.
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service_definition_parameters.html
  #
  # It is the ECS Service that defines the scaling configurations.
  # However, this parameter is to define "how many tasks" hence task_ABC.
  #--------------------------------------------------------------------------------
  description = "The number of containers to run for the service XYZ."
  type = number
}


#================================================================================
# Microservice
#================================================================================
variable "microservice_XYZ_name" {
  description = "Name of the micro service XYZ"
  type = string
}

variable "ENABLE_ECS_EC2_CONNECTION_DEBUG" {
  description = "[WARNING] Flag for debug to all connectivities to all ECS EC2 ports from everywhere"
  default = false
  type = bool
}

#--------------------------------------------------------------------------------
# For HTTP/HTTPS, ALB will be used, otherwise NLB.
# See outputs.tf for the logic.
#--------------------------------------------------------------------------------
variable "protocol_for_microservice_XYZ" {
  description = "The network protocol of the service for the service consumer to use. HTTP|HTTPS|TCP|UDP|TPC_UDP (This will control ALB or NLB)"
  type = string
}
variable "client_port_for_microservice_XYZ" {
  description = "The exposed network port of the service for the service consumer to use."
  type = number
}

/*
# ELB target group healthheck specifies "traffic-port", hence no configuration for
# healthcheck port.

variable "ec2_healthcheck_port_for_microservice_XYZ" {
  description = "EC2 port to healthcheck the micro service XYZ. This is NOT a dynamic port, hence a static value"
  type = number
}
*/

variable "ec2_host_port_for_microservice_XYZ" {
  description = "EC2 host port for the micro service (a docker container) XYZ. For dynamic port mapping, set 0."
  type = number
}
variable "docker_container_port_for_microservice_XYZ" {
  description = "Docker container internal port for the micro service XYZ."
  type = number
}

#--------------------------------------------------------------------------------
# Service Health check protocol/port
# TODO: Verify if ECS will update target group healthcheck for dynamic port mapping
# ANSWER: it does if "traffic-port" has been specified
# https://aws.amazon.com/premiumsupport/knowledge-center/dynamic-port-mapping-ecs/
# Important: To route health check traffic correctly when you create a target group,
# choose Target Groups, and then Actions. Edit health check. For Port, choose traffic port.
#--------------------------------------------------------------------------------
/*
Set ec2_host_port_for_microservice_XYZ and docker_container_port_for_microservice_XYZ as the
output values of these variables.

variable "ec2_healthcheck_protocol_for_microservice_XYZ" {
  description = "Healtchcheck protocol to test EC2 port response from service XYZ"
  type = string
}
variable "ec2_healthcheck_port_for_microservice_XYZ" {
  description = "Healtchcheck port to test EC2 port response from service XYZ"
  type = number
}
*/

# ECS service definition - healthCheckGracePeriodSeconds parameter.
# Seconds that ECS service scheduler should ignore ELB  health checks, container health checks,
# and Route 53 health checks after a task enters a RUNNING state.
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service_definition_parameters.html
#
# Do NOT confuse with Health Check Grace Period of the EC2 Auto Scaling Group.
# https://docs.aws.amazon.com/autoscaling/ec2/userguide/healthcheck.html#health-check-grace-period
variable "ecs_service_ABC_healthcheck_grece_period" {
  description = "Seconds that ECS service scheduler should ignore ELB, docker container, Route 53 health checks after a ECS task enters a RUNNING state."
  type = number
}


#--------------------------------------------------------------------------------
# ELB
#
# For ALB network protcol, see Listeners for Your Application Load Balancers.
# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-listeners.html
# Protocols: HTTP, HTTPS
# Ports: 1-65535
#
# For NLB network protocol, see Listeners for Your NLB.
# https://docs.aws.amazon.com/elasticloadbalancing/latest/network/load-balancer-listeners.html
# Protocols: TCP, TLS, UDP, TCP_UDP
# Ports: 1-65535
#
# Always use stickiness and hard-coded in alb.tf in the alb module.
#--------------------------------------------------------------------------------
/*
# This is to be determined by the service protocol

variable "elb_type_for_microservice_XYZ" {
  description = "ELB type (network|appliation) to use for the micro service XYZ"
  type = string
}
variable "elb_protocol_for_microservice_XYZ" {
  description = "ELB protoocol for the micro service XYZ. HTTTP|HTTPS for application type and  TCP|TLS|UDP|TCP_UDP for network"
  type = string
}

#--------------------------------------------------------------------------------
# ALB SG (NLB has no SG)
#--------------------------------------------------------------------------------
/*
# No need to configure ALB SG to control the egress access to the EC2 instance/port as
# ECS service automatically update the ELB target group to point to the EC2 instance/port.

variable "alb_sg_egress_from_client_port_for_microservice_XYZ" {
  description = "ALB Security Group egress from-port towards the target EC2 of micro service XYZ. 49153 for dynamic port mapping."
  type = number
}
variable "alb_sg_egress_to_client_port_for_microservice_XYZ" {
  description = "ALB Security Group egress to-port of towards the target EC2 of micro service XYZ. 65535 for dynamic port mapping."
  type = number
}

variable "alb_sg_egress_cidr_blocks_for_microservice_XYZ" {
  description = "ALB Security Group egress CIDR blocks within which the IP address of the target EC2 of micro service XYZ exists."
}
*/
/*
This should be the same with client_port_for_microservice_XYZ.

variable "alb_sg_ingress_from_client_port_for_microservice_XYZ" {
  description = "ALB Security Group ingress from-port to accept external incoming connection to microservice_XYZ"
  type = number
}
variable "alb_sg_ingress_to_client_port_for_microservice_XYZ" {
  description = "ALB Security Group ingress to-port to accept external incoming connection to microservice_XYZ"
  type = number
}
*/



# TODO: Move keypair public key value to global parameter.
/*
resource "aws_key_pair" "this" {
  key_name   = "hogehoge"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDwGqmwLfBJ1MaFJy5cEoCFAAYxmTuJJc8VrAe26hSa55Mj7kofCfx/iPquRF2fXzDrPiRc+dK1n79UO9JREj4DFOX79bpBgvjc6Q9ljph0vsVPrk7jdgrpupRemvfPVNNgwzi5EcLfEMjmMH8Yl0yPA5sI0hNKJxKE9tqZqVNP+eiCstU0lnwVJsVlLWZ7rhxotbw/Dzt58+GSfA2TthfgN/EdNlwesRIqkreoUhNO/nZzARNpOv9rm/lH0DZpdLF8skTJINHHVJOe93DQbOvoJPoybsJ5y27k4I8POz5oi9d48rkHyFgAG2952ADWr/zOOuoZChB36uwBOhSu9BWxcznkor0QIBqHqDV4o9rDPmPtZRLbhfreKY0B4uP7x/eRwsiVZ8DZDJVsQue0Au+Gx09GRsu1GnIULm5Lp387tHLjQZQTZA6R4LTUdR2uEJ2GtGc+6rnEkc4Awgx40mE1SYoYqwO3D4b0SCbhxskp7vxl8iD1LV5zkvJG9+XfNgc= userm4p@WS226440"
}
*/