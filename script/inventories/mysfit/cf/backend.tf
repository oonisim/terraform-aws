terraform {
  backend "s3" {
    encrypt = true
  }
}

#--------------------------------------------------------------------------------
# Common/global configuration store
#--------------------------------------------------------------------------------
data "terraform_remote_state" "common" {
  backend = "s3"
  config = {
    encrypt = "true"
    bucket  = var.BACKEND_BUCKET
    key     = "${var.backend_key_common}"
  }
}

#--------------------------------------------------------------------------------
# Cognito Userpool IDP
#--------------------------------------------------------------------------------
data "terraform_remote_state" "cognito_idp" {
  backend = "s3"
  config = {
    encrypt = "true"
    bucket  = "${var.BACKEND_BUCKET}"
    key     = "${var.backend_key_cognito_idp}"
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


#--------------------------------------------------------------------------------
# API Click events
#--------------------------------------------------------------------------------
data "terraform_remote_state" "userevent" {
  backend = "s3"
  config = {
    encrypt = "true"
    bucket  = "${var.BACKEND_BUCKET}"
    key     = "${var.backend_key_userevent}"
  }
}

#--------------------------------------------------------------------------------
# API question
#--------------------------------------------------------------------------------
data "terraform_remote_state" "questionnaire" {
  backend = "s3"
  config = {
    encrypt = "true"
    bucket  = "${var.BACKEND_BUCKET}"
    key     = "${var.backend_key_questionnaire}"
  }
}

/*
#--------------------------------------------------------------------------------
# API recommendation
#--------------------------------------------------------------------------------
data "terraform_remote_state" "recommendation" {
  backend = "s3"
  config = {
    encrypt = "true"
    bucket  = "${var.BACKEND_BUCKET}"
    key     = "${var.backend_key_recommendation}"
  }
}
*/