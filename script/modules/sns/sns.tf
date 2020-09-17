resource "aws_sns_topic" "this" {
  #--------------------------------------------------------------------------------
  # Let the terraform auto-create name
  # When "name" is not set, then the aws_sns_topic data source refering to the topic
  # will wait for the SNS topic to be created.
  # Otherwise, the data source thinks the topic already exists and try to retrieve its
  # details via data source causing an error:
  #--------------------------------------------------------------------------------
  # [Error]
  # No topic with name "notification" found in this region.
  #--------------------------------------------------------------------------------
  #name_prefix = "${var.PROJECT}_${var.ENV}_${var.sns_topic_name}"

  # No error above is observed, hence reverted to name.
  name              = "${var.PROJECT}_${var.ENV}_${var.sns_topic_name}"
  display_name      = "${var.PROJECT}_${var.ENV}_${var.sns_topic_name}"
  kms_master_key_id = "alias/aws/sns"
}

