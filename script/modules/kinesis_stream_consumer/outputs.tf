output "lambda_function_arn" {
  value = "${aws_lambda_function.kinesis_consumer.arn}"
}

output "lambda_function_nanme" {
  value = "${aws_lambda_function.kinesis_consumer.function_name}"
}

output "lambda_function_id" {
  value = "${aws_lambda_function.kinesis_consumer.id}"
}

output "lambda_function_invoke_arn" {
  value = "${aws_lambda_function.kinesis_consumer.invoke_arn}"
}


