#--------------------------------------------------------------------------------
# AWS SNS notification to Slack channel.
# https://registry.terraform.io/modules/terraform-aws-modules/notify-slack/aws
#--------------------------------------------------------------------------------
#--------------------------------------------------------------------------------
# The module itself needs to be updated for terraform 0.12 or later.
#--------------------------------------------------------------------------------
/*
module "slack" {
  source  = "terraform-aws-modules/notify-slack/aws"

  create = "${var.enable_slack_integration}"
  slack_channel     = "${var.slack_channel_name}"
  slack_webhook_url = "${var.slack_channel_webhook_url}"
  slack_username    = "${var.slack_username}"

  #--------------------------------------------------------------------------------
  # Make sure the name attribute of the sns is not specified in TF resource.
  # When "name" is not set, then the module will wait for the SNS topic to be created.
  # Otherwise, the module thinks the topic already exists and try to retrieve its
  # details via data source causing an error:
  #--------------------------------------------------------------------------------
  # [Error]
  # module.notify-slack.data.aws_sns_topic.this:
  # data.aws_sns_topic.this:
  # No topic with name "notification_on_transcoded" found in this region.
  #--------------------------------------------------------------------------------
  create_sns_topic  = false
  sns_topic_name    = "${aws_sns_topic.this.name}"

  # Lambda function that sends messages to the slack channel on the SNS topic events.
  lambda_function_name = "notify_slack_${var.slack_channel_name}"
}
*/
