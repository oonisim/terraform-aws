#--------------------------------------------------------------------------------
# WAF for ALB need to use WAF Regional
# Reference:
# https://medium.com/kudos-engineering/terraforming-amazons-web-application-firewall-e5c22b7d317d
#--------------------------------------------------------------------------------

# RegexMatch does not not work
# https://github.com/terraform-providers/terraform-provider-aws/issues/12051
/*
# Value to set to the X-Origin-Verify header
resource "random_string" "cf_custom_header_origin_verify" {
  length = 16
  special = false
  override_special = "/@£$"
}


locals {
  x_origin_verify_values = [
    random_string.cf_custom_header_origin_verify.result
  ]
}

#--------------------------------------------------------------------------------
# WACL to controol HTTP AWS resource access
#--------------------------------------------------------------------------------
resource "aws_wafregional_web_acl" "enforce_cloudfront" {
  name = "waf-regional-acl-enforce-cloudfront"
  metric_name = "wacl-regional-enforce-cloudfront"
  default_action {
    type = "BLOCK"
  }
  rule {
    action {
      type = "ALLOW"
    }
    priority = 1
    type = "REGULAR"
    rule_id = aws_wafregional_rule.allow_from_cloudfront.id
  }
}

#--------------------------------------------------------------------------------
# Rule to allow access only from CloudFront (use CloudFront customer header)
#--------------------------------------------------------------------------------
resource "aws_wafregional_rule" "allow_from_cloudfront" {
  name = "wafruleallowfromcf"
  metric_name = "wafruleallowfromcf"

  predicate {
    type = "RegexMatch"
    negated = false
    data_id = aws_waf_regex_match_set.allow_from_cloudfront.id
  }
  depends_on = [
    aws_waf_regex_match_set.allow_from_cloudfront,
    aws_waf_regex_pattern_set.allow_from_cloudfront
  ]
}

#--------------------------------------------------------------------------------
# Matching conditions (condition = which target to check with what value)
#--------------------------------------------------------------------------------
# Match type and target
resource "aws_waf_regex_match_set" "allow_from_cloudfront" {
  name = "condition"

  regex_match_tuple {
    field_to_match {
      type = "HEADER"
      data = "X-Origin-Verify"
    }

    regex_pattern_set_id = aws_waf_regex_pattern_set.allow_from_cloudfront.id
    text_transformation = "NONE"
  }
}

# Values to match in the condition
resource "aws_waf_regex_pattern_set" "allow_from_cloudfront" {
  name = "values"
  #regex_pattern_strings = local.x_origin_verify_values
  regex_pattern_strings = [
    "abc"
  ]
}
*/

#--------------------------------------------------------------------------------
# WACL to controol HTTP AWS resource access
#--------------------------------------------------------------------------------
resource "aws_wafregional_web_acl" "enforce_cloudfront" {
  name = "WACLEnforceCloudfront"
  metric_name = "WACLEnforceCloudfront"
  default_action {
    type = "BLOCK"
  }
  rule {
    action {
      type = "ALLOW"
    }
    priority = 1
    type = "REGULAR"
    rule_id = aws_wafregional_rule.aws_condition_match_header_origin_verify.id
  }
}

resource "aws_wafregional_rule" "aws_condition_match_header_origin_verify" {
  name = "WAFRuleAllowFromCloudFront"
  metric_name = "WAFRuleAllowFromCloudFront"

  predicate {
    data_id = aws_wafregional_byte_match_set.aws_condition_match_header_origin_verify.id
    negated = false
    type = "ByteMatch"
  }
}

#--------------------------------------------------------------------------------
# create-byte-match-set
# https://docs.aws.amazon.com/cli/latest/reference/waf-regional/create-byte-match-set.html
#--------------------------------------------------------------------------------
resource "aws_wafregional_byte_match_set" "aws_condition_match_header_origin_verify" {
  name = "MatchHeaderOriginVerify"
  byte_match_tuples {
    positional_constraint = "EXACTLY"
    target_string         = "TO_BE_REPLACED"
    text_transformation   = "NONE"

    field_to_match {
      type = "HEADER"
      data = "X-Origin-Verify"
    }
  }
}
