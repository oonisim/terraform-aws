resource "aws_kinesis_firehose_delivery_stream" "es" {
  name        = "${var.PROJECT}-${var.ENV}-${var.name}"
  destination = "elasticsearch"

  s3_configuration {
    role_arn           = "${aws_iam_role.firehose.arn}"
    bucket_arn         = "${local.bucket_arn}"
    buffer_size        = "${var.buffer_size}"
    buffer_interval    = "${var.buffer_interval}"
    #compression_format = "GZIP"
    compression_format = "UNCOMPRESSED"
  }

  elasticsearch_configuration {
    domain_arn = "${var.es_domain_arn}"
    role_arn   = "${aws_iam_role.firehose.arn}"
    index_name = "${var.es_index_name}"
    type_name  = "${var.es_type_name}"
  }
}