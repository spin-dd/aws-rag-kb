variable "symbol" {}
variable "kb" {}
variable "domain_name" {}
variable "region" {
  default = "us-west-2"
}
variable "ecr" {

}

locals {
  host = "kb"
  domain_names = {
    demo = "demo.${var.domain_name}"
    # prod = var.domain_nam
  }
  zones = {
    "${local.host}.${local.domain_names.demo}" = data.aws_route53_zone.kx["demo"]
    #"kb.${local.domain_names.prod}" = data.aws_route53_zone.kx["prod"]

  }
  routes = [
    "/faq",
    "/faq_stream",
  ]
  cert_subject = "${local.host}.${local.domain_names.demo}" # "kb.${local.domain_names.prod}"
  cert_subject_altnames = [
    # "kb.${local.domain_names.demo}"
  ]
}

