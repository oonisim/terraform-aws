
terraform {
  required_version = ">= 0.12"
}

variable "terraform_aws_modules_version" {
  description = "Terraform registry AWS VPC version"
  default = "2.33.0"
}