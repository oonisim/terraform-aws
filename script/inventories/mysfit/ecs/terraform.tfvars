#--------------------------------------------------------------------------------
# ECS cluster
#--------------------------------------------------------------------------------
# Use common module variable
#ecs_cluster_name = "TBD"

#--------------------------------------------------------------------------------
# LB
#--------------------------------------------------------------------------------
# This MUST match with the one defined in aws_lb_target_group.

#--------------------------------------------------------------------------------
# ECS service docker container
#--------------------------------------------------------------------------------
ecs_service_launch_type = "EC2"
# TODO: Use the global parameter service name
/*
ecs_service_name = "TBD"
ecs_service_container_port = 3000
ecs_service_host_port = 8080
ecs_service_desired_count = 2 # Consider the number of AZ for even deployment
ecs_healthcheck_grace_period_seconds = 180

#microservice_XYZ_name = "MicroServiceXYZ"
*/
# Dockerfile and image
#microservice_XYZ_dir  = "docker/XYZ"
microservice_XYZ_dir  = "docker/mysfit"
microservice_XYZ_dockerfile_template_name = "Dockerfile.template"
microservice_XYZ_dockerfile_name = "Dockerfile"

#--------------------------------------------------------------------------------
# TODO:
# Need to introduce a way to incrementally update.
# Using "latest" can cause mixed versions in the environment. e.g. while pervious
# version is in the environment, a build run and new image is pushed as "latest".
# Then a new container is launched and the new image is used for the new one.
#--------------------------------------------------------------------------------
microservice_XYZ_build_version = "v1"
microservice_XYZ_release_tag = "latest"

