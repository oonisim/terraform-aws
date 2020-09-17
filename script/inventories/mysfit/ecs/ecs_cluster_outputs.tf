output "aws_ecs_cluster_name" {
  value = "${aws_ecs_cluster.this.name}"
}
output "aws_ecs_cluster_arn" {
  value = "${aws_ecs_cluster.this.arn}"
}
output "aws_ecs_cluster_id" {
  value = "${aws_ecs_cluster.this.id}"
}