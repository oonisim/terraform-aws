#!/usr/bin/env bash
#--------------------------------------------------------------------------------
# EC2
#--------------------------------------------------------------------------------
function terminate_ec2_instances {
    echo "Checking running EC2 instances..."
    if [[ "${VPC_ID}x" != "x" ]]; then
      ec2_instances=($(aws ec2 describe-instances --filters "Name=vpc-id,Values=${VPC_ID}" | jq -r ".Reservations[].Instances[].InstanceId"))
      if [[ ${#ec2_instances[@]} -gt 0 ]]; then
          echo "Terminating EC2 instances [${ec2_instances[@]}] in VPC [${VPC_ID}]..."
          aws ec2 terminate-instances --instance-ids "${ec2_instances[@]}"
      fi
    fi
}

#--------------------------------------------------------------------------------
# VPC
#--------------------------------------------------------------------------------
function get_vpc_id {
    VPC_DIR="vpc"
    echo "Retrieving VPC information..."
    export VPC_ID=$(cd "${VPC_DIR}" && terraform output | sed -n 's/^vpc_id = \(.*\)$/\1/p')
    echo "VPC_ID=[${VPC_ID}]"
}

