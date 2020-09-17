output "firehose_name" {
  value = "${aws_kinesis_firehose_delivery_stream.es.name}"
}
output "firehose_id" {
  value = "${aws_kinesis_firehose_delivery_stream.es.id}"
}
output "firehose_arn" {
  value = "${aws_kinesis_firehose_delivery_stream.es.arn}"
}
output "firehose_destination" {
  value = "${aws_kinesis_firehose_delivery_stream.es.destination}"
}
output "firehose_destination_id" {
  value = "${aws_kinesis_firehose_delivery_stream.es.destination_id}"
}
output "firehose_destination_version_id" {
  value = "${aws_kinesis_firehose_delivery_stream.es.version_id}"
}
output "firehose_destination_s3_configuration" {
  value = "${aws_kinesis_firehose_delivery_stream.es.s3_configuration}"
}
output "firehose_destination_elasticsearch_configuration" {
  value = "${aws_kinesis_firehose_delivery_stream.es.elasticsearch_configuration}"
}