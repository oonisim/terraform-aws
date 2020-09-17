#--------------------------------------------------------------------------------
# CF
# Do not specify origin specifics here but in cf_locals.tf.
#--------------------------------------------------------------------------------

# Value to set to the X-Origin-Verify header
resource "random_string" "cf_custom_header_origin_verify" {
  length = 16
  special = false
  override_special = "/@£$"
}

module "cf_s3_web" {

  source = "../../../modules/terraform-aws-cloudfront"
  enable = true
  default_root_object = var.default_root_object

  app_name    = var.app_name
  role        = "frontend"
  environment = var.ENV
  comment     = "${var.PROJECT}-${var.ENV}-${var.app_name} frontend created by Terraform"

  #--------------------------------------------------------------------------------
  # Geo restrictions
  #--------------------------------------------------------------------------------
  restriction_type = "none"
  locations = []

  #--------------------------------------------------------------------------------
  # WAF
  #--------------------------------------------------------------------------------
  waf_web_acl_id = ""

  #--------------------------------------------------------------------------------
  # Origins
  #--------------------------------------------------------------------------------
  s3_origin_configs = local.s3_origin_configs
  custom_origin_configs = local.custom_origin_configs

  #--------------------------------------------------------------------------------
  # Behaviours
  #--------------------------------------------------------------------------------
  default_cache_behavior = local.default_cache_behavior
  ordered_cache_behavior_variables = local.ordered_cache_behaviors

  tags = {
      Name:"Project"
      Value: var.PROJECT
    }

}

#--------------------------------------------------------------------------------
# Expose I/F
#--------------------------------------------------------------------------------
locals {
  cf_web_domain_name = module.cf_s3_web.cloudfront_domain_name
  cf_web_id = module.cf_s3_web.cloudfront_id
}
