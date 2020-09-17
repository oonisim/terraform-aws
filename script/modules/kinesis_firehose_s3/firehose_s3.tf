resource "aws_kinesis_firehose_delivery_stream" "s3" {
  name        = "${var.PROJECT}-${var.ENV}-firehose-extended-s3-${var.name}"

    # (Optional) should not be enabled when a kinesis stream is configured as the source
  server_side_encryption {
    enabled = true
  }

  destination = "extended_s3"
  extended_s3_configuration {
    # Destination
    bucket_arn = local.bucket_arn
    error_output_prefix = "error/${var.name}"

    role_arn   = aws_iam_role.firehose.arn

    #--------------------------------------------------------------------------------
    # Buffer incoming data to the specified size, in MBs, before delivering it to the destination.
    # The default value is 5. Recommend setting to greater than typically ingest in 10 seconds.
    #--------------------------------------------------------------------------------
    buffer_size        = var.buffer_size
    buffer_interval    = var.buffer_interval
    compression_format = var.compression_format
    #compression_format = "UNCOMPRESSED"

    #--------------------------------------------------------------------------------
    # Lambda transformer
    #--------------------------------------------------------------------------------
    processing_configuration {
      enabled = "true"
      processors {
        type = "Lambda"
        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = data.aws_lambda_function.transform.qualified_arn
        }
      }
    }

    cloudwatch_logging_options {
      enabled = var.cloudwatch_loggroup_name == null ? false : true
      log_group_name = var.cloudwatch_loggroup_name
      log_stream_name = var.cloudwatch_logstream_name
    }
  }
}