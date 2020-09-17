terraform {
  backend "s3" {
    encrypt = true
  }
}

#--------------------------------------------------------------------------------
# S3
#--------------------------------------------------------------------------------
data "terraform_remote_state" "s3" {
  backend = "s3"
  config = {
    encrypt = "true"
    bucket  = var.BACKEND_BUCKET
    key     = var.backend_key_s3
  }
}

#--------------------------------------------------------------------------------
# API GW
#--------------------------------------------------------------------------------
data "terraform_remote_state" "apigw" {
  backend = "s3"
  config = {
    encrypt = "true"
    bucket  = "${var.BACKEND_BUCKET}"
    key     = "${var.backend_key_apigw}"
  }
}
