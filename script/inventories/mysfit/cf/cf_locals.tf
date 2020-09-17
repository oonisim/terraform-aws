#--------------------------------------------------------------------------------
# CF dependency injection
# cf.tf does not have specific knowledge on origins or behaviours.
# Those are contained in cf_local.tf and injected into cf.tf.
#--------------------------------------------------------------------------------

#--------------------------------------------------------------------------------
# CF S3 origins
#--------------------------------------------------------------------------------
locals {
  s3_origin_configs = [
    local.s3_origin_config_s3_web
  ]

  s3_origin_config_s3_web = {
    origin_id              = "S3-${var.PROJECT}-${var.ENV}-${local.s3_web_bucket_name}"
    origin_path            = ""

    domain_name            = local.s3_web_bucket_domain_name
    origin_access_identity = local.cf_origin_access_identitiy_s3_web_path
  }
}

#--------------------------------------------------------------------------------
# CF custom origin configs
#--------------------------------------------------------------------------------
locals {
  custom_origin_configs = [
  ]
}


#--------------------------------------------------------------------------------
# CF behaviours
#--------------------------------------------------------------------------------
locals {
  default_cache_behavior = local.s3_web_cache_behavior
  ordered_cache_behaviors = []

  s3_web_cache_behavior = {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = local.s3_origin_config_s3_web.origin_id
    query_string           = false
    forward                = "none"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
}


