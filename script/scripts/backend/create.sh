#!/usr/bin/env bash
#--------------------------------------------------------------------------------
# Create Terraform S3 backend for a project/env.
#--------------------------------------------------------------------------------
# [Design]
# - Isolate the state file of each project environment in its own S3 bucket.  
# - The bucket name is ${var.PREFIX}-${var.PROJECT}-${var.ENV}.
# - Use environment variables to provide the values.
# TF_VAR_PREFIX
# TF_VAR_PROJECT
# TF_VAR_ENV
# 
# [State file location]
# Use variable STATE_FILE_DIR to specify where to store the state file.
#--------------------------------------------------------------------------------
set -eu
DIR=$(realpath $(dirname $0))

#--------------------------------------------------------------------------------
# AWS
#--------------------------------------------------------------------------------
export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:?'Set AWS_DEFAULT_REGION'}"
export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:?'Set AWS_ACCESS_KEY_ID'}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:?'Set AWS_SECRET_ACCESS_KEY'}"

export TF_VAR_REGION=${AWS_DEFAULT_REGION}

#--------------------------------------------------------------------------------
# Backend S3 bucket configuration
#--------------------------------------------------------------------------------
echo "STATE_FILE_DIR (Directory to place the Terraform state file for the project/environment)?"
read STATE_FILE_DIR
STATE_FILE_DIR=$(realpath ${STATE_FILE_DIR})
export STATE_FILE_DIR="${STATE_FILE_DIR:?'Set STATE_FILE_DIR'}"

if false
then
echo "TF_VAR_PREFIX (String to identify Terraform bucket in S3)?"
read TF_VAR_PREFIX

echo "TF_VAR_PROJECT (Project name)?"
read TF_VAR_PROJECT

echo "TF_VAR_ENV (Target environment in the project)?"
read TF_VAR_ENV

echo "TF_VAR_REGION (Target AWS region)?"
read TF_VAR_REGION

export TF_VAR_PREFIX="${TF_VAR_PREFIX:?'Set TF_VAR_PREFIX'}"
export TF_VAR_PROJECT="${TF_VAR_PROJECT:?'Set TF_VAR_PROJECT'}"
export TF_VAR_ENV="${TF_VAR_ENV:?'Set TF_VAR_ENV'}"
export TF_VAR_REGION="${TF_VAR_REGION:?'Set TF_VAR_REGION'}"
fi

#--------------------------------------------------------------------------------
# Copy S3 configuration files
#--------------------------------------------------------------------------------
(cd ${DIR} && cp *.tf "${STATE_FILE_DIR}/")

#--------------------------------------------------------------------------------
# Create Remote state in S3
#--------------------------------------------------------------------------------
# [Init]
# https://www.terraform.io/docs/commands/init.html#usage
# It is recommended to run Terraform with the current working directory set to 
# the root directory of the configuration, and omit the DIR argument.
# 
# .terraform directory is created only in the current directory, not in the
# ${STATE_FILE_DIR} directory specified to terraform init. Therefore, need to
# change directory to the ${STATE_FILE_DIR}.
# (https://www.terraform.io/docs/configuration/environment-variables.html#tf_data_dir)
#--------------------------------------------------------------------------------
if false
then
    terraform init \
        ${STATE_FILE_DIR}
    
    terraform plan \
        -lock=true \
        -out="${STATE_FILE_DIR}/tfplan" \
    
    terraform apply \
        -lock=true \
        -auto-approve \
        -state-out=${STATE_FILE_DIR} \
        ${STATE_FILE_DIR}
else
    cd ${STATE_FILE_DIR}
    terraform init
    terraform plan
    terraform apply
fi