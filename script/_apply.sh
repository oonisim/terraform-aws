#!/usr/bin/env bash
export PYTHONPATH="~/.local/lib"

#--------------------------------------------------------------------------------
# Apply all
#--------------------------------------------------------------------------------
commands=(apply)
for command in ${commands[@]}
do
  components=(common vpc s3     nlb ecs     ec2 dynamodb_mysfits cognito_idp  apigw lambda userevent questionnaire sagemaker recommendation cf test)
  for component in "${components[@]}"
  do
      echo "--------------------------------------------------------------------------------"
      echo "[$component]"
      tf ${component} ${command}
  done
done


