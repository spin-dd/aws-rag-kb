
# Resource: aws_s3_bucket
# https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/resources/s3_bucket
resource "aws_s3_bucket" "this" {
  bucket        = "${var.symbol.prefix}-datasource"
  force_destroy = true # デモ環境なので destroy を許す
}
