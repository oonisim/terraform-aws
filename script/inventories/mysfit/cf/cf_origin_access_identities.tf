#--------------------------------------------------------------------------------
# OAI
#--------------------------------------------------------------------------------
resource "aws_cloudfront_origin_access_identity" "s3_web" {
  comment = "access-identity-${var.PROJECT}-${var.ENV}-s3-web"
}

#--------------------------------------------------------------------------------
# Expose I/F
# Do not allow direct refernce to the implmentations to have clear boundary & inter-operability.
#--------------------------------------------------------------------------------
locals {
  cf_origin_access_identity_arns = [
    aws_cloudfront_origin_access_identity.s3_web.iam_arn
  ]

  cf_origin_access_identitiy_s3_web_path = aws_cloudfront_origin_access_identity.s3_web.cloudfront_access_identity_path

}