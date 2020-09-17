#!/bin/bash
FUNCTION_NAME="masa_ecs_monolith_transform"
FUNCTION_ALIAS="v1"

aws lambda invoke --function-name ${FUNCTION_NAME} \
--qualifier ${FUNCTION_ALIAS} \
--payload file://./event.json \
response.json

