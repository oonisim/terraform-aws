output "es_domain_name" {
  value = "${aws_elasticsearch_domain.this.domain_name}"
}
output "es_domain_arn" {
  value = "${aws_elasticsearch_domain.this.arn}"
}
output "es_domain_endpoint" {
  value = "${aws_elasticsearch_domain.this.endpoint}"
}
output "es_domain_elasticsearch_version" {
  value = "${aws_elasticsearch_domain.this.elasticsearch_version}"
}
output "es_role_name" {
  value = "${aws_iam_role.es.name}"
}
output "es_role_arn" {
  value = "${aws_iam_role.es.arn}"
}
