variable "authorizer_identity_validation_expression" {
  default = "^Bearer [-0-9a-zA-z\\.]*$"
}

variable "authorizer_result_ttl_in_seconds" {
  default = "3600"
}

