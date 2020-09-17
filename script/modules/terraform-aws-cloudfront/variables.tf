variable "app_name" {
  default = ""
}

variable "role" {
  default = "cf"
}

variable "environment" {
  default = ""
}

variable "enable" {
  default = true
}

variable "is_ipv6_enabled" {
  default = true
}

variable "comment" {
  default = "Cloudfront distribution created by Terraform"
}

variable "default_root_object" {
  default = ""
}

variable "aliases" {
  default     = []
  description = "Extra CNAMEs (alternate domain names), if any, for this distribution."
  type        = list(string)
}

#--------------------------------------------------------------------------------
# geo_restriction
# https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html#restrictions-arguments
#--------------------------------------------------------------------------------
variable "restriction_type" {
  description = "Geographic restrictions and restriction_type (Required) specify the way to restrict the countriies: none, whitelist, or blacklist."
  default = "none"
}
variable "locations" {
  type        = list(string)
  default     = []
  description = "The ISO 3166-1-alpha-2 codes for which you want CloudFront either to distribute your content: https://www.iso.org/obp/ui/#search"
}


variable "price_class" {
  default = "PriceClass_200"
}

variable "cloudfront_default_certificate" {
  type    = bool
  default = true
}

# Logging configuration optional
variable "cloudfront_logging_enabled" {
  type        = bool
  default     = false
  description = "If true, mandatory values are needed"
}

variable "logging_config" {

  default = {
    bucket          = null
    include_cookies = null
    prefix          = null
  }
}


variable "s3_origin_configs" {

  type        = list(map(string))
  description = "Define values for origin or multiple origins"
  default     = [
    {
      domain_name = "TO_BE_REPLACED"
      origin_path = "TO_BE_REPLACED"
      origin_id = "TO_BE_REPLACED"
      origin_access_identity = "TO_BE_REPLACED"
    }
  ]
}

variable "custom_origin_configs" {
  description = "Define values for origin or multiple origins"
  default = [
    {
      domain_name              = ""
      origin_id                = ""
      origin_path              = "/"
      http_port                = "80"
      https_port               = "443"
      origin_keepalive_timeout = 5
      origin_read_timeout      = 30
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = ["TLSv1.1", "TLSv1.2"]
      custom_headers           = {
        name  = "X-Origin-Verify"
        value = "TO_BE_UPDATED"
      }

    }
  ]
}

variable "default_cache_behavior" {

  default = {

    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = ""
    query_string           = false
    forward                = "none"
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
}
variable "ordered_cache_behavior_variables" {
  default = [
    {
      path_pattern           = "/"
      allowed_methods        = ["GET", "HEAD", "OPTIONS"]
      cached_methods         = ["GET", "HEAD", "OPTIONS"]
      target_origin_id       = ""
      min_ttl                = 0
      default_ttl            = 86400
      max_ttl                = 31536000
      compress               = true
      viewer_protocol_policy = "redirect-to-https"
      #forwarded_values
      query_string = false
      headers      = ["Origin"]
      forward      = "none"  # Cookie
      whitelisted_names = []
    },
    {
      path_pattern           = "/content/test2/*"
      allowed_methods        = ["GET", "HEAD", "OPTIONS"]
      cached_methods         = ["GET", "HEAD", "OPTIONS"]
      target_origin_id       = ""
      min_ttl                = 0
      default_ttl            = 86400
      max_ttl                = 31536000
      compress               = true
      viewer_protocol_policy = "redirect-to-https"
      #forwarded_values
      query_string = false
      headers      = ["Origin"]
      forward      = "none"
      whitelisted_names = []
    },
  ]
}

variable "waf_web_acl_id" {
  description = "The Id of the AWS WAF web ACL that is associated with the distribution. "
  default     = ""
}

variable "viewer_certificate_type" {
  description = "Type of certificate, cloudfront or acm,or custom"
  default = "cloudfront"
}
variable "acm_certificate_arn_config" {
  default = {
    acm_certificate_arn      = null
    minimum_protocol_version = "TLSv1.1_2016"
    ssl_support_method       = "sni-only"
  }
}

variable "tags" {
  description = "A map of tags to add to your cloudfront distribution"
  default     = {}
  type        = map
}

