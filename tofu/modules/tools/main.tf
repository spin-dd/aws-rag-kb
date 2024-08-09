# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lambda_function
resource "aws_lambda_function" "this" {
  #
  function_name = "${var.symbol.prefix}-tool"
  architectures = [
    "arm64"
  ]
  #
  package_type = "Image"
  image_uri    = "${var.ecr.repository_url}:latest"
  role         = aws_iam_role.this.arn # saving ロール
  #
  memory_size = 128
  timeout     = 60
  environment {
    variables = {
      "LOGGROUP" = "${aws_cloudwatch_log_group.this.name}"
    }
  }
  tracing_config {
    mode = "PassThrough"
  }
  lifecycle {
    ignore_changes = [
      environment,
    ]
  }
  logging_config {
    log_format = "Text"
    log_group  = aws_cloudwatch_log_group.this.name
  }
}
