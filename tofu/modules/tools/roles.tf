# ロール
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "this" {
  path               = "/service-role/"
  name               = "${var.symbol.prefix}-tools-lambda"
  assume_role_policy = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com", "events.amazonaws.com", "lambda.amazonaws.com"]
    }

  }
}


# ポリシー 
# EC2 管理者 
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "ec2" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

# CloudFron管理者
resource "aws_iam_role_policy_attachment" "cloudfront" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/CloudFrontFullAccess"
}

# ECS管理者
resource "aws_iam_role_policy_attachment" "ecs" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

# RDS管理者
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy
resource "aws_iam_role_policy" "rds" {
  # インラインポリシー
  name   = "${var.symbol.prefix}-tools-rds"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.rds.json
}

data "aws_iam_policy_document" "rds" {
  statement {
    actions = [
      "rds:StopDBInstance",
      "rds:StartDBInstance",
      "rds:StopDBCluster",
      "rds:StartDBCluster",
    ]
    resources = ["*"]
  }
}



# lambda 実行
resource "aws_iam_role_policy" "lambda" {
  # インラインポリシー
  name   = "${var.symbol.prefix}-tools-lambda"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.lambda.json
}


data "aws_iam_policy_document" "lambda" {
  statement {
    actions = [
      "lambda:InvokeFunction",
    ]
    effect    = "Allow"
    resources = [aws_lambda_function.this.arn]
  }
}
