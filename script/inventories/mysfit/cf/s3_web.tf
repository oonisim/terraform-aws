#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# As S3 web is created with CF, the access to CF can be redirect to S3 acusing
# access denied with OAI.
#
# Per our AWS documentation (http://docs.aws.amazon.com/AmazonS3/latest/dev/Redirects.html),
# Due to the distributed nature of Amazon S3, requests can be temporarily routed to the wrong facility.
# This is most likely to occur immediately after buckets are created or deleted. For example,
# if you create a new bucket and immediately make a request to the bucket, you might receive a temporary redirect
# https://forums.aws.amazon.com/thread.jspa?threadID=216814
# https://stackoverflow.com/questions/38735306/aws-cloudfront-redirecting-to-s3-bucket
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

#--------------------------------------------------------------------------------
# S3 bucket for static web
#--------------------------------------------------------------------------------
module "s3_web" {
  source                         = "../../../modules/s3_web"
  PROJECT                        = var.PROJECT
  ENV                            = var.ENV
  bucket_name                    = var.bucket_name
  bucket_description             = var.bucket_description
  allow_cf_access_only           = true
  cf_origin_access_identity_arns = local.cf_origin_access_identity_arns
}

/*
resource "aws_s3_bucket_object" "index_html" {
  bucket = module.s3_web.bucket

  # TODO: Inject the NLB URL dynamically into index.html.
  key    = "index.html"
  content_type = "text/html"
  source = "web/index.html"

  #--------------------------------------------------------------------------------
  # Canned ACL
  # https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl
  #--------------------------------------------------------------------------------
  # Remove all public access permission and allow only OAI to be able read the bucket.
  # https://serverfault.com/questions/923731/how-do-i-limit-s3-object-access-to-cloudfront-only
  #--------------------------------------------------------------------------------
  #acl    = "public-read"
  acl    = "private"
  #--------------------------------------------------------------------------------

  etag   = filemd5("web/index.html")
}
*/

#--------------------------------------------------------------------------------
# Recreate *.html file so that aws_s3_bucket_object will pick them up.
# After they are deleted at terraform destroy or at refresh state,
# aws_s3_bucket_object fails to pick them up to upload to S3 as they do not exist.
#--------------------------------------------------------------------------------
resource "null_resource" "restore_local_files" {
  for_each = fileset("${path.module}/web/", "*.html.template")
  provisioner "local-exec" {
    command = <<EOF
set -ue
touch ${replace("${path.module}/web/${each.value}", "/\\.template$/", "")}
EOF
  }
  provisioner "local-exec" {
    when    = "destroy"
    command = <<EOF
set -ue
touch ${replace("${path.module}/web/${each.value}", "/\\.template$/", "")}
EOF
  }
}

#--------------------------------------------------------------------------------
# Inject AWS resource references for JS/AWS SDK
#--------------------------------------------------------------------------------
resource "local_file" "web_files" {
  for_each = fileset("${path.module}/web/", "*.html.template")

  content = templatefile("${path.module}/web/${each.value}", {
    REPLACE_ME_REGION                      = var.REGION
    REPLACE_ME_API_MYSFIT_ENDPOINT         = local.apigw_mysfit_invoke_url
    REPLACE_ME_API_CLICK_ENDPOINT          = local.apigw_userevent_invoke_url
    REPLACE_ME_API_QUESTION_ENDPOINT       = local.apigw_questionnaire_invoke_url
    REPLACE_ME_COGNITO_USER_POOL_ID        = local.cognito_userpool_id
    REPLACE_ME_COGNITO_USER_POOL_CLIENT_ID = local.cognito_userpool_client_id
    # Module 07 recommendation
    #    REPLACE_ME_RECOMMENDATION_ENDPOINTE  = local.apigw_recommendation_invoke_url
  })

  filename = replace("${path.module}/web/${each.value}", "/\\.template$/", "")

  depends_on = [
    null_resource.restore_local_files
  ]
}

#--------------------------------------------------------------------------------
# S3 static web content upload
# TODO: Invaliate CF upon web file updates
#--------------------------------------------------------------------------------
resource "aws_s3_bucket_object" "web_files" {
  # for_each argument must be a map, or set of strings
  for_each = toset(flatten([
    fileset("${path.module}/web/", "*.html"),
    fileset("${path.module}/web/", "js/*"),
  ]))

  # TODO: Inject the NLB URL dynamically into index.html.
  bucket       = module.s3_web.bucket
  key          = each.value
  content_type = "text/html"
  source       = "${path.module}/web/${each.value}"

  #--------------------------------------------------------------------------------
  # Canned ACL
  # https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl
  #--------------------------------------------------------------------------------
  # Remove all public access permission and allow only OAI to be able read the bucket.
  # https://serverfault.com/questions/923731/how-do-i-limit-s3-object-access-to-cloudfront-only
  #--------------------------------------------------------------------------------
  #acl    = "public-read"
  acl = "private"
  #--------------------------------------------------------------------------------

  #--------------------------------------------------------------------------------
  # The updates on the file needs to be done before running Terraform.
  # Hash is calculated before the apply phase, the hash value of dynamically created
  # file will not be available. For now, use timestamp if possible to upload everytime.
  #--------------------------------------------------------------------------------
  #etag = filemd5("${path.module}/web/${each.value}.template")
  etag = timestamp()

  depends_on = [
    local_file.web_files
  ]
}

#--------------------------------------------------------------------------------
# Expose (I/F)
# Do not allow direct reference into the implementation objects.
#--------------------------------------------------------------------------------
locals {
  s3_web_bucket_name        = module.s3_web.bucket
  s3_web_bucket_domain_name = module.s3_web.bucket_domain_name
}

