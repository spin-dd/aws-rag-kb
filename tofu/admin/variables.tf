variable "service" {
  type    = string
  default = "sample"
}
variable "admin_env" {
  type    = string
  default = "admin"
}
variable "admin_region" {
  type    = string
  default = "us-west-2"
}

# 管理対象環境(CSVストリング)
variable "admin_targets" {
  type    = string
  default = ""
}

locals {
  region = var.admin_region
  symbol = {
    service = var.service
    env     = var.admin_env
    prefix  = "${var.service}-${var.admin_env}"
  }
  envs = split(",", var.admin_targets)
}
