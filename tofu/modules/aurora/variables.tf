variable "symbol" {}
variable "region" {}
#
variable "database" {}
variable "subnet_group_name" {}
variable "cluster_zones" {}
variable "instance_zone" {}


locals {
  table_name = "${var.database.name.schema}.${var.database.name.table}"
}
