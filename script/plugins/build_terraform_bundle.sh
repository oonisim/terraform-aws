#!/bin/bash
REPOSITORY_DIR="~/repositories/git"
cd ${REPOSITORY_DIR}
git clone https://github.com/hashicorp/terraform.git
cd terraform
go install .
go install ./tools/terraform-bundle

# Verify
ls $(go env GOPATH)/bin