#!/bin/bash
set -ue

eval "$(jq -r '@sh "AWS_REGION=\(.aws_region) AWS_VPC_ID=\(.aws_vpc_id) AWS_NLB_NAME=\(.aws_nlb_name)"')"

export PYTHONPATH="~/.local/lib"
AWS_NLB_IPS="$(aws ec2 describe-network-interfaces --region ${AWS_REGION} --filters \
  "Name=description,Values=ELB net/${AWS_NLB_NAME}/*" \
  "Name=vpc-id,Values=${AWS_VPC_ID}" \
  "Name=status,Values=in-use" \
  "Name=attachment.status,Values=attached" \
| jq -c '.NetworkInterfaces[].PrivateIpAddresses[].PrivateIpAddress' | jq -s . > aws.log 2>&1)"


cat <<EOF
{
   "error": "$?"
}
EOF