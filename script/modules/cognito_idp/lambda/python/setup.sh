#!/usr/bin/env bash
#--------------------------------------------------------------------------------
# Setup the lambda requirements
#--------------------------------------------------------------------------------
#rm -rf *.pyc __pycache__
DIR=$(realpath $(dirname $0))
(
#  cd ${DIR} && pydoc modules . | grep -e jose -e botocore -e boto3 || \
  cd ${DIR}  && pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org -r requirements.txt -t .
)

#pip install PyJWT -t .