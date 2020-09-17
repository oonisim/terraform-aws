#!/usr/bin/env bash
#set -ex
#--------------------------------------------------------------------------------
# Run terraform configuration for an environment.
# 
# [Structure]
# .
# |-<component>
# |-<component>.<sub-component>.<sub-component>
#
# The component shares <component> as the key of its backend.
# e.g. network and network.post_config shares "network" as its backend key.
#--------------------------------------------------------------------------------

DIR=$(realpath $(dirname $0))
clear

#----------------------------------------------------------------------
# Project
#----------------------------------------------------------------------
. ${DIR}/_project.sh


cd ${DIR}/inventories  # Must be here

. ${DIR}/_select_env.sh
. ${DIR}/_check_aws_id.sh
. ${DIR}/_aws.sh

. ${DIR}/_tf.sh

#set -e

components=( $(for i in $(ls -d */ | grep -i -v -E 'backend|NOT_USED|images|docs'); do basename $(realpath $i); done) )
components+=('exit')
while true
do
    echo "Which option in [${components[@]}]? Select a number."
    
    select component in "${components[@]}"
    do
        case ${component} in 
            exit)
                echo "Exiting..."
                break 2 
                ;;
            *)
                commands=(validate plan apply output update init show pull providers destroy "0.12upgrade")
                select command in ${commands[@]}
                do
                  if [[ "${command}" == "destroy" ]]; then
                      if [[ "${component}" == "executor" || "${component}" == "vpc" || "${component}" == "asg" ]]; then
                          if [[ "${VPC_ID}" == "" ]] ; then get_vpc_id ; fi
                          terminate_ec2_instances
                      fi
                      components=($(echo "${components[@]} " | tac -s ' '))
                  fi
                  tf ${component} ${command}
                  break
                done
        esac
        echo "Press any key to proceed..."
    done
done
