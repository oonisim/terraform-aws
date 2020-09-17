variable "PROJECT" {
  type = string
}
variable "ENV" {
  type = string
}

variable "loggroup_name" {
  type = string
  default = null
}

variable "logsteram_name" {
  description = "(Optional) Name of the log stream"
  type = string
  default = null
}