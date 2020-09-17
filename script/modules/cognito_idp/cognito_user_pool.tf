resource "aws_cognito_user_pool" "this" {
  name = "${var.PROJECT}_${var.ENV}_${var.name}"
  admin_create_user_config {

    #--------------------------------------------------------------------------------
    # (Optional)True if only the administrator is allowed to create user profiles.
    # Set to False if users can sign themselves up via an app.
    #
    # For web application to let users sign-up on their own, set to false.
    # Otherwise "SignUp is not permitted for this user pool"
    #--------------------------------------------------------------------------------
    allow_admin_create_user_only = var.allow_admin_create_user_only

    # [DEPRECATED] Use password_policy.temporary_password_validity_days
    #unused_account_validity_days = 90
  }

  password_policy {
    minimum_length                   = 6
    require_lowercase                = false
    require_numbers                  = false
    require_symbols                  = false
    require_uppercase                = false
    temporary_password_validity_days = 90
  }

  schema {
    #--------------------------------------------------------------------------------
    #  Registration/sign-in fails without mail
    #--------------------------------------------------------------------------------
    required = true
    name     = "email"
    string_attribute_constraints {
      min_length = 7
      max_length = 100
    }

    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = false

  }

  #--------------------------------------------------------------------------------
  # (Optional) Specifies email or phonecan be used as usernames at signs up.
  #--------------------------------------------------------------------------------
  username_attributes      = [
    "email"
  ]
  auto_verified_attributes = var.auto_verified_attributes
  tags                     = {
    "Name"        = var.PROJECT
    "Environment" = var.ENV
  }
}

resource "aws_cognito_user_pool_client" "this" {
  name                = "${var.PROJECT}_${var.ENV}"
  user_pool_id        = aws_cognito_user_pool.this.id
  generate_secret     = var.enable_client_secret
  explicit_auth_flows = [
    "ADMIN_NO_SRP_AUTH"
  ]
}

