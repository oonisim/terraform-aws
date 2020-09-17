#!/usr/bin/env bash
#--------------------------------------------------------------------------------
# Apply all
#--------------------------------------------------------------------------------
commands=(output)
for command in ${commands[@]}
do
  components=(vpc s3 sns identity_pool executor apigw)
  for component in "${components[@]}"
  do
      echo "--------------------------------------------------------------------------------"
      echo "[$component]"
      tf ${component} ${command}
  done
done

