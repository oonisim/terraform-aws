#!/usr/bin/env bash
set -eu
DIR=$(realpath $(dirname $0))

#--------------------------------------------------------------------------------
# AWS
#--------------------------------------------------------------------------------
export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:?'Set AWS_DEFAULT_REGION'}"
export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:?'Set AWS_ACCESS_KEY_ID'}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:?'Set AWS_SECRET_ACCESS_KEY'}"

#--------------------------------------------------------------------------------
# Backend S3 bucket configuration
#--------------------------------------------------------------------------------
echo "STATE_FILE_DIR (Directory of the Terraform state file for the project/environment)?"
read STATE_FILE_DIR
STATE_FILE_DIR=$(realpath ${STATE_FILE_DIR})

echo "TF_VAR_PREFIX (String to identify Terraform bucket in S3)?"
read TF_VAR_PREFIX

echo "TF_VAR_PROJECT (Project name)?"
read TF_VAR_PROJECT

echo "TF_VAR_ENV (Target environment in the project)?"
read TF_VAR_ENV

export STATE_FILE_DIR="${STATE_FILE_DIR:?'Set STATE_FILE_DIR'}"
export TF_VAR_PREFIX="${TF_VAR_PREFIX:?'Set TF_VAR_PREFIX'}"
export TF_VAR_PROJECT="${TF_VAR_PROJECT:?'Set TF_VAR_PROJECT'}"
export TF_VAR_ENV="${TF_VAR_ENV:?'Set TF_VAR_ENV'}"

#--------------------------------------------------------------------------------
# Destroy remote state bucket in S3
#--------------------------------------------------------------------------------
if false
then
    terraform init \
        ${STATE_FILE_DIR}
    
    terraform plan \
        -destroy \
        -var-file="${STATE_FILE_DIR}/terraform.tfvars" \
        -lock=true \
        -out="${STATE_FILE_DIR}/tfplan" \
        "${STATE_FILE_DIR}"
    
    terraform destroy \
        -var-file="${STATE_FILE_DIR}/terraform.tfvars" \
        -lock=true \
        "${STATE_FILE_DIR}"
else
    cd "${STATE_FILE_DIR}"

    terraform init
    terraform plan \
        -destroy \
        -lock=true

    terraform destroy \
        -lock=true
fi