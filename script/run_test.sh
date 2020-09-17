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

clear

set -e

cd ${DIR}/modules
(cd ./cognito_idp/lambda && run_test.sh)
(cd ./executor/lambda && run_test.sh)
