variable "PROJECT" {
}

variable "ENV" {
}

variable "identity_provider_name" {
}

variable "allow_admin_create_user_only" {
  description = "(Optional) If only the administrator is allowed to create user profiles. Set to False if users can sign themselves up via an app."
  default = true
}

variable "auto_verified_attributes" {
  description = "(Optional) The attributes to be auto-verified. Possible values: email, phone_number."
  type = list(string)
  default = []
}

#--------------------------------------------------------------------------------
# The Javascript SDK doesn't support Apps with a Client Secret.
# Need to disable "Generate client secret" when creating a User Pool.
# Error "Unable to verify secret hash for client in Amazon Cognito Userpools"
# https://stackoverflow.com/questions/37438879/unable-to-verify-secret-hash-for-client-in-amazon-cognito-userpools
#--------------------------------------------------------------------------------
variable "enable_client_secret" {
  description = "Optionally create a secret for User Pool client secret or not. Disable it for Javascript JDK."
}
