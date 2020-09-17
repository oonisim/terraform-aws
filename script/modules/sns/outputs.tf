output "sns_topic_arn" {
  value = aws_sns_topic.this.arn
}

output "sns_topic_name" {
  value = aws_sns_topic.this.name
}

/*
output "lambda_function_notify_slack_name" {
  value = "${module.slack.notify_slack_lambda_function_name}"
}

output "lambda_function_notify_slack_arn" {
  value = "${module.slack.notify_slack_lambda_function_arn}"
}

output "lambda_function_notify_slack_invoke_arn" {
  value = "${module.slack.notify_slack_lambda_function_invoke_arn}"
}

output "lambda_function_notify_slack_iam_role_name" {
  value = "${module.slack.lambda_iam_role_name}"
}

output "lambda_function_notify_slack_iam_role_arn" {
  value = "${module.slack.lambda_iam_role_arn}"
}
*/
