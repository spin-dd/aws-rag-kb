variable "service" {
  type    = string
  default = "sample"
}
variable "admin_region" {
  type    = string
  default = "us-west-2"
}
variable "env" {
  type    = string
  default = "ai"
}
variable "region" {
  type    = string
  default = "us-west-2"

}

locals {
  region = var.region
  symbol = {
    service = var.service
    env     = var.env
    prefix  = "${var.service}-${var.env}"
  }
}
