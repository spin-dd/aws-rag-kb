variable "symbol" {}
variable "awstools" {}
variable "aurora_cluster" {}

locals {
  events = {
    rds_stop = {
      params = {
        args = ["rds", "stop-cluster", var.aurora_cluster.cluster_identifier]
      }
      cron_expr = "cron(0 21 ? * Mon-Sun *)"
    }
  }
}
