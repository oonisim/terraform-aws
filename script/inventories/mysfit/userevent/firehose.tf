module "firehose_cloudwatch" {
  source = "../../../modules/cloudwatch"

  PROJECT = "${var.PROJECT}"
  ENV     = "${var.ENV}"

  loggroup_name  = var.firehose_cloudwatch_loggroup_name
  logsteram_name = var.firehose_cloudwatch_logstream_name
}

# Expose I/F
locals {
  cloudwatch_loggroup_name  = module.firehose_cloudwatch.cloudwatch_loggroup_name
  cloudwatch_loggroup_arn   = module.firehose_cloudwatch.cloudwatch_loggroup_arn
  cloudwatch_logstream_name = module.firehose_cloudwatch.cloudwatch_logstream_name
}


module "firehose" {
  source = "../../../modules/kinesis_firehose_s3"

  PROJECT = var.PROJECT
  ENV     = var.ENV

  name    = var.firehose_name

  #--------------------------------------------------------------------------------
  # Lambda transofrmer
  #--------------------------------------------------------------------------------
  lambda_function_name = local.lambda_transform_function_name
  lambda_alias_name    = local.lambda_transform_function_alias

  #--------------------------------------------------------------------------------
  # S3 Destination
  #--------------------------------------------------------------------------------
  bucket_name = local.bucket_name

  #--------------------------------------------------------------------------------
  # Stream buffer
  #--------------------------------------------------------------------------------
  buffer_size     = var.buffer_size
  buffer_interval = var.buffer_interval

  #--------------------------------------------------------------------------------
  # Cloudwatch
  #--------------------------------------------------------------------------------
  cloudwatch_loggroup_name  = local.cloudwatch_loggroup_name
  cloudwatch_logstream_name = local.cloudwatch_logstream_name
}

# Expose I/F
locals {
  firehose_name = module.firehose.firehose_name
  firehose_arn  = module.firehose.firehose_arn
}