#!/bin/bash
set -e
#--------------------------------------------------------------------------------
# Due to AWS ECS bug, cannot delete Capacity Provider once created,
# re-use the capacity-provider created.
# [ECS] Add the ability to delete an ASG capacity provider. #632
# https://github.com/aws/containers-roadmap/issues/632
#
# [Test]
# echo -n '{ "aws_region": "us-east-2", "ecs_cluster_name": "masa_ecs_monolith_myecs", "capacity_provider_name": "masa-ecs_monolith-ecs-cluster-capacity-provider" }' \
# | ./put_capacity_provider.sh
#--------------------------------------------------------------------------------
eval "$(jq -r '@sh "aws_region=\(.aws_region) ecs_cluster_name=\(.ecs_cluster_name) capacity_provider_name=\(.capacity_provider_name)"')"

#CAPACITY_PROVIDERS=$(aws ecs describe-capacity-providers | jq '.capacityProviders[] | select(.status=="ACTIVE" and .name!="FARGATE" and .name!="FARGATE_SPOT") | .name')

export PYTHONPATH="~/.local/lib"
json=$(aws ecs put-cluster-capacity-providers \
  --cluster "${ecs_cluster_name}"  \
  --capacity-providers "${capacity_provider_name}" \
  --default-capacity-provider-strategy "capacityProvider=${capacity_provider_name},base=1,weight=1" \
  --region "${aws_region}" \
  2>&1)

jq -n --arg json "${json}" '{"json":$json}'