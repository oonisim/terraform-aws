#--------------------------------------------------------------------------------
# SNS publish intergartion with Slack.
#--------------------------------------------------------------------------------
module "sns" {
  # Terraform currently does not allow interpolation on the module source path.
  source                    = "../../../modules/sns"

  PROJECT                   = "${var.PROJECT}"
  ENV                       = "${var.ENV}"

  sns_topic_name            = "${var.sns_topic_name}"
}

# Expose I/F
locals {
  sns_topic_arn = module.sns.sns_topic_arn
  sns_topic_name = module.sns.sns_topic_name
}

# Unsupported protocols include the following:
# The endpoint needs to be authorized and does not generate an ARN until the target email address has been validated.
# This breaks the Terraform model and as a result are not currently supported.
# * email -- delivery of message via SMTP
# * email-json -- delivery of JSON-encoded message via SMTP
/*
resource "aws_sns_topic_subscription" "email" {
  topic_arn = module.sns.sns_topic_arn
  protocol  = "email"
  endpoint  = var.email_address
}
*/

resource "null_resource" "sns_subscribe_to_email" {
  provisioner "local-exec" {
    command = <<EOF
aws sns subscribe \
    --topic-arn ${local.sns_topic_arn} \
    --protocol email \
    --notification-endpoint ${var.questionnaire_admin_email_address}
EOF
  }
}