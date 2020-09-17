#!/bin/bash
#--------------------------------------------------------------------------------
# Describe DOCKER container instance, NOT ECS EC2 instance.
# In the AWS documentation, container instance is EC2, but in CLI, it is Docker.
#
# See https://www.terraform.io/docs/providers/external/data_source.html#processing-json-in-shell-scripts
# [Test]
# echo '{"aws_region":"us-east-2","ecs_cluster_name":"masa_ecs-monolith_myecs","docker_instance_id":"..."}' | ./test_ecs_ec2.sh
#--------------------------------------------------------------------------------
set -e

# DO not put any stdout as they will go back to the external provider and causes errors due to unexpected return strings.
# Do not access the piple stdin as it will be consumed and jq eill get nothing.

#--------------------------------------------------------------------------------
# @sh tells JQ to geneerate shelll safe string such as single/double quoted.
# "aws_region=\(.aws_region)" is JQ string interpolation where "\(...)" is the variable reference.
#--------------------------------------------------------------------------------
# DO NOT CONSUME stdin e.g. echo "$(jq -r '@sh "aws_region=\(.aws_region) ecs_cluster_name=\(.ecs_cluster_name) docker_instance_id=\(.docker_instance_id)"')"
eval "$(jq -r '@sh "aws_region=\(.aws_region) ecs_cluster_name=\(.ecs_cluster_name) docker_instance_id=\(.docker_instance_id)"')"
ec2_ecs_connected="false"
ec2_ecs_connected=$(aws ecs describe-container-instances --cluster ${ecs_cluster_name} --container-instances "${docker_instance_id}" --query 'containerInstances[*].agentConnected')
jq -n --arg ec2_ecs_connected "${ec2_ecs_connected}"'{"ec2_ecs_connected":$ec2_ecs_connected}'
