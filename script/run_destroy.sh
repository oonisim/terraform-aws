#!/usr/bin/env bash
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
#
# TODO:
# Terminate all the EC2 instances in the VPN before destroy
#--------------------------------------------------------------------------------
DIR=$(realpath $(dirname $0))

#----------------------------------------------------------------------
# Project
#----------------------------------------------------------------------
. ${DIR}/_project.sh

. ${DIR}/_check_aws_id.sh

cd ${DIR}/inventories  # Must be here

clear
. ${DIR}/_select_env.sh

. ${DIR}/_tf.sh
. ${DIR}/_aws.sh

set -e

get_vpc_id
terminate_ec2_instances

. ${DIR}/_destroy.sh
