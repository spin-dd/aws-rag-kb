variable "symbol_admin_service" {
  type    = string
  default = "sample"
}
variable "symbol_admin_env" {
  type    = string
  default = "admin"
}
variable "admin_region" {
  type    = string
  default = "us-west-2"
}

# 管理対象環境(CSVストリング)
variable "admin_envs" {
  type    = string
  default = ""
}

locals {
  region = var.admin_region
  symbol = {
    service = var.symbol_admin_service
    env     = var.symbol_admin_env
    prefix  = "${var.symbol_admin_service}-${var.symbol_admin_env}"
  }
  envs = split(",", var.admin_envs)
}
