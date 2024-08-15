# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository
resource "aws_ecr_repository" "this" {
  for_each     = toset(local.apps)
  name         = "${var.symbol.prefix}-${each.key}"
  force_delete = true # デモ環境なのでdestoryを許す
}
