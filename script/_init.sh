#!/usr/bin/env bash
#--------------------------------------------------------------------------------
# Init all
#--------------------------------------------------------------------------------
find . -type d -name '.terraform' | xargs rm -rf
commands=(init validate)
for command in ${commands[@]}
do
  components=(common vpc s3 alb nlb ecs asg ec2 dynamodb_mysfits cognito_idp apigw lambda userevent questionnaire sagemaker recommendation cf test)
  for component in "${components[@]}"
  do
      echo "--------------------------------------------------------------------------------"
      echo "[$component]"
      tf ${component} ${command}
  done
done
