#--------------------------------------------------------------------------------
# IAM Policies generated
#--------------------------------------------------------------------------------
output "iam_policy_allow_s3_arn" {
  value = "${aws_iam_policy.allow_s3.arn}"
}
output "iam_policy_deny_s3_arn" {
  value = "${aws_iam_policy.deny_s3.arn}"
}
output "iam_policy_allow_s3" {
  value = "${aws_iam_policy.allow_s3.policy}"
}
output "iam_policy_deny_s3" {
  value = "${aws_iam_policy.deny_s3.policy}"
}

#--------------------------------------------------------------------------------
# S3 buckets and objects to apply the policy against.
#--------------------------------------------------------------------------------
output "s3_arns" {
  value = "${concat(var.s3_arns, local.s3_object_arns)}"
}


#--------------------------------------------------------------------------------
# Return a list of policies created and the number of policies.
#--------------------------------------------------------------------------------
locals {
  policy_arns = [
    "${aws_iam_policy.allow_s3.arn}",
    "${aws_iam_policy.deny_s3.arn}"
  ]
}
output "policy_arns" {
  value = "${local.policy_arns}"
}
output "count" {
  value = "${length(local.policy_arns)}"
}
