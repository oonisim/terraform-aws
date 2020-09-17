#!/usr/bin/env bash

export AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:?'Set AWS_ACCOUNT_ID'}"
export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:?'Set AWS_DEFAULT_REGION'}"
export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:?'Set AWS_ACCESS_KEY_ID'}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:?'Set AWS_SECRET_ACCESS_KEY'}"

repository_name=ecs_test_masa_api

$(aws ecr get-login --no-include-email --region $AWS_DEFAULT_REGION)

docker build -t api .
docker tag api:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${repository_name}:v1
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${repository_name}:v1