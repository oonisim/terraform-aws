#!/usr/bin/env bash
#--------------------------------------------------------------------------------
# Destroy all
#--------------------------------------------------------------------------------
commands=(destroy)
for command in ${commands[@]}
do
  #--------------------------------------------------------------------------------
  # TODO: Need a solution to stop EC2 instances in a manner ASG will not start new ones.
  # Before destoying ECS, the EC2 instances in the cluster need to be stopped first.
  # Cannot destroy ASG because ECS Cluster capacity provider has dependency.
  # (Curse of circular dependency of ECS Cluster -> ASG -> EC2/Userdata -> ECS Cluster)
  #--------------------------------------------------------------------------------
  components=(common vpc s3 alb nlb ecs asg ec2 dynamodb_mysfits cognito_idp  apigw lambda userevent questionnaire sagemaker recommendation cf test)
  if [[ "${command}" == "destroy" ]]; then
      components=($(echo "${components[@]} " | tac -s ' '))
  fi
  for component in "${components[@]}"
  do
      echo "--------------------------------------------------------------------------------"
      echo "[$component]"
      tf ${component} ${command}
  done
done

