locals {
  domain_name = "${replace(lower(substr("${var.PROJECT}-${var.ENV}-${var.name}", 0, 28)), "/[._]/", "")}"
}
resource "aws_elasticsearch_domain" "this" {
  domain_name = "${local.domain_name}"
  elasticsearch_version = "${var.es_elasticsearch_version}"
  access_policies = "${data.aws_iam_policy_document.allow_aws_access_es.json}"
  #--------------------------------------------------------------------------------
  # How to allow access to ES/Kibana from Web browsers -> Use source IP (not 0.0.0.0)
  # {"Message":"User: anonymous is not authorized to perform: es:ESHttpGet"}
  # https://aws.amazon.com/premiumsupport/knowledge-center/anonymous-not-authorized-elasticsearch/
  # https://stackoverflow.com/questions/32978026/proper-access-policy-for-amazon-elastic-search-cluster
  #--------------------------------------------------------------------------------
/*
  access_policies = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Principal": {
        "AWS": "*"
      },
      "Action": "es:*",
      "Effect": "Allow",
      "Resource": "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${local.domain_name}/*",
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": ["0.0.0.0"]
        }
      }
    }
  ]
}
POLICY
*/
  cluster_config {
    instance_type            = "${var.es_instance_type}"
    instance_count           = "${var.es_instance_count}"
    dedicated_master_enabled = "${var.es_instance_count >= var.es_dedicated_master_threshold ? true : false}"
    dedicated_master_count   = "${var.es_instance_count >= var.es_dedicated_master_threshold ? 3 : 0}"
    dedicated_master_type    = "${var.es_instance_count >= var.es_dedicated_master_threshold ? (var.es_dedicated_master_type != "false" ? var.es_dedicated_master_type : var.es_instance_type) : ""}"
    zone_awareness_enabled   = "${var.es_zone_awareness}"
  }

  ebs_options {
    ebs_enabled = "${var.es_ebs_volume_size > 0 ? true : false}"
    volume_size = "${var.es_ebs_volume_size}"
    volume_type = "${var.es_ebs_volume_type}"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = "${local.cloudwatch_loggroup_arn}"
    log_type                 = "INDEX_SLOW_LOGS"
  }

  depends_on = [
    "data.aws_iam_policy_document.allow_es_access_cloudwatch"
  ]
}