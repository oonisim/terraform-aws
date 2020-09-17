output "microservice_XYZ_client_url" {
  value = "http://${local.elb_dns_name}:${local.client_port_for_microservice_XYZ}"
}