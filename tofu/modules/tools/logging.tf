
# CloudWatch Logging
resource "aws_cloudwatch_log_group" "this" {
  name              = "${var.symbol.prefix}-tools"
  retention_in_days = 7
}


# Lambda 関数のロールにポリシー適用
# 
resource "aws_iam_role_policy" "logging" {
  role   = aws_iam_role.this.name # Lambda 関数
  name   = "${var.symbol.prefix}-tools-logging"
  policy = data.aws_iam_policy_document.logging.json
}


data "aws_iam_policy_document" "logging" {
  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup"]
    resources = ["*"]
  }
  statement {
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    effect    = "Allow"
    resources = ["${aws_cloudwatch_log_group.this.arn}:*"]
  }
}
