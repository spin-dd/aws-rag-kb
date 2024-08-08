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

variable "domain_name" {
  type = string
}

variable "database_table_name" {
  type    = string
  default = "rag.bedrock.kb"
}
variable "database_user" {
  type = string
}
variable "database_master_user" {
  type = string
}

locals {
  region = var.region
  symbol = {
    service = var.service
    env     = var.env
    prefix  = "${var.service}-${var.env}"
  }

  database = {
    name        = regex("^(?P<db>[^\\.]+).(?P<schema>[^\\.]+).(?P<table>[^\\.]+)$", var.database_table_name)
    user        = regex("^(?P<username>[^.]+)\\s(?P<password>[^.]+)$", var.database_user)
    master_user = regex("^(?P<username>[^.]+)\\s(?P<password>[^.]+)$", var.database_master_user)
  }
  # Aurora RAG Table
  field_mapping = jsondecode(file("${path.module}/conf/field_mapping.json"))
}
