variable "name_prefix" {
  type = string
}

variable "name_suffix" {
  type = string
}

variable "environment" {
  type = string
}

variable "has_cert" {
  type    = bool
  default = true
}

variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "security_groups" {
  type = list(string)
}

variable "health_check_path" {
  type    = string
  default = "/"
}

variable "certificate_arn" {
  type    = string
  default = ""
}

variable "port" {
  type    = number
  default = 80
}

variable "protocol" {
  type    = string
  default = "HTTP"
}

variable "timeout" {
  type    = string
  default = 120
}

variable "interval" {
  type    = string
  default = 150
}
