#--------------------------------------------------------------------------------
# CloudWatch log group for API Gateway access logging
# https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-logging.html#set-up-access-logging-using-console
# To enable access logging, choose Enable Access Logging under Custom Access Logging.
# Then type the ARN of a log group in CloudWatch Group. Type a log format in Log Format.
# You can choose CLF, JSON, XML, or CSV to use one of the provided examples as a guide.
# https://forums.aws.amazon.com/thread.jspa?messageID=811315
#--------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "access_log" {
  name              = "/${var.PROJECT}/${var.ENV}/apigw/accesslogs"
  retention_in_days = 90
  tags = {
    Project = var.PROJECT
  }
}

