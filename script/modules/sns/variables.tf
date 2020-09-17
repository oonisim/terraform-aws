variable "PROJECT" {
}

variable "ENV" {
}

variable "sns_topic_name" {
  description = "SNS topic name to subscribe"
}

variable "enable_slack_integration" {
  description = "Flat to enable Slack integration"
  default     = false
}

variable "slack_username" {
  description = "Displayed username"
  default     = ""
}

variable "slack_channel_name" {
  description = "Slack channel for debug echo"
  default     = ""
}

variable "slack_channel_webhook_url" {
  description = "Slack incoming webhook URL for the slack channel"
  default     = ""
}

