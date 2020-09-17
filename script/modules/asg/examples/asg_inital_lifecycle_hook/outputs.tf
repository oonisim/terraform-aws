output "launch_configuration_id" {
  description = "The ID of the launch configuration"
  value       = "${module.example.launch_configuration_id}"
}

output "autoscaling_group_id" {
  description = "The autoscaling group id"
  value       = "${module.example.autoscaling_group_id}"
}
