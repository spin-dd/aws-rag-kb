# Resource: aws_s3_bucket
# https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/resources/s3_bucket

resource "aws_s3_bucket" "this" {
  bucket = "${var.symbol.prefix}-state"
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name                           = "admin-bucket"
    terraform                      = "true"
    "${var.symbol.service}-deploy" = "${var.symbol.env}"
  }
}


# Resource: aws_s3_bucket_server_side_encryption_configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Resource: https://registry.terraform.io/providers/hashicorp/aws/4.8.0/docs/resources/dynamodb_table
resource "aws_dynamodb_table" "this" {
  for_each = toset(var.envs)
  #
  name         = "${var.symbol.prefix}-statedb-${each.key}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Name                           = "statedb"
    env                            = each.key
    terraform                      = "true"
    "${var.symbol.service}-deploy" = "${var.symbol.env}"
  }
}
