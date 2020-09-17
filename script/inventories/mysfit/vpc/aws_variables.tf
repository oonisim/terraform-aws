variable "REGION" {
  description = "AWS region to be set via the TF_VAR enviornment variable"
}

/*
# Backend S3 bucket file for IAM component (should be <component>.tfstate)
variable "backend_key_iam" {
  default = "iam.tfstate"
}
*/
