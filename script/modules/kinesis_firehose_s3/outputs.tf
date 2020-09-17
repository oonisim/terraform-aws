output "firehose_name" {
  value = "${aws_kinesis_firehose_delivery_stream.s3.name}"
}
output "firehose_id" {
  value = "${aws_kinesis_firehose_delivery_stream.s3.id}"
}
output "firehose_arn" {
  value = "${aws_kinesis_firehose_delivery_stream.s3.arn}"
}
output "firehose_destination" {
  value = "${aws_kinesis_firehose_delivery_stream.s3.destination}"
}
output "firehose_destination_id" {
  value = "${aws_kinesis_firehose_delivery_stream.s3.destination_id}"
}
output "firehose_destination_version_id" {
  value = "${aws_kinesis_firehose_delivery_stream.s3.version_id}"
}
output "firehose_destination_extended_s3_configuration" {
  value = "${aws_kinesis_firehose_delivery_stream.s3.extended_s3_configuration}"
}
