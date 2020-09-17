#--------------------------------------------------------------------------------
# Dockerfile and image
#--------------------------------------------------------------------------------
/*variable "microservice_XYZ_name" {
  description = "container name"
}
*/
variable "microservice_XYZ_dir" {
  description = "Relative path to the container directory"
}
variable "microservice_XYZ_dockerfile_template_name" {
  description = "container dockerfile template filename"
}
variable "microservice_XYZ_dockerfile_name" {
  description = "Dockerfile for the service"
}
variable "microservice_XYZ_build_version" {
  description = "container image version, e.g. v1"
}
variable "microservice_XYZ_release_tag" {
  description = "Release tag of the image pushed, e.g. latest"
}
