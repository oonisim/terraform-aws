#!/usr/bin/env bash
set -ex
DIR=$(realpath $(dirname $0))
cd ${DIR}

system=$(uname)
if [ "$system" == "Linux" ]; then
  ln -s terraform-bundle terraform-bundle-linux-x64
elif [ "$system" == "Darwin" ]; then
  ln -s terraform-bundle terraform-bundle-darwin-x64
fi

chmod u+x terraform-bundle
rm -f terraform_*bundle*.zip && ./terraform-bundle package terraform_bundle.hcl && unzip -o terraform_*bundle*.zip
