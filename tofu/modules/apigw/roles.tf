# ロール
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "kb_lambda" {
  path               = "/service-role/"
  name               = "${var.symbol.prefix}-kb-lambda"
  assume_role_policy = data.aws_iam_policy_document.kb_lambda.json
}

data "aws_iam_policy_document" "kb_lambda" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# ポリシー 
# 
resource "aws_iam_role_policy" "kb_bedrock" {
  role   = aws_iam_role.kb_lambda.name
  name   = "${var.symbol.prefix}-kb-bedrock"
  policy = data.aws_iam_policy_document.kb_bedrock.json
}


data "aws_iam_policy_document" "kb_bedrock" {
  statement {
    effect    = "Allow"
    actions   = ["bedrock:*"]
    resources = ["*"]
  }
}


