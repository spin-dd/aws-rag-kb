variable "symbol_service" {
  type    = string
  default = "sample"
}
variable "symbol_env" {
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
    service = var.symbol_service
    env     = var.symbol_env
    prefix  = "${var.symbol_service}-${var.symbol_env}"
  }
}
