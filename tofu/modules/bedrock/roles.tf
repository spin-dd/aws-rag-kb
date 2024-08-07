
# ロール
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role

resource "aws_iam_role" "this" {
  name               = "${var.symbol.prefix}-kb"
  assume_role_policy = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["bedrock.amazonaws.com"]
    }
  }
}

# ポリシー

# 1. テキストベクトル化
resource "aws_iam_role_policy" "embedding" {
  role   = aws_iam_role.this.name
  name   = "${var.symbol.prefix}-kb-embedding"
  policy = data.aws_iam_policy_document.embedding.json
}


data "aws_iam_policy_document" "embedding" {
  statement {
    effect    = "Allow"
    actions   = ["bedrock:InvokeModel"]
    resources = [var.embedding_model_arn]
  }
}

# 2. RDSクラスタ

resource "aws_iam_role_policy" "rds" {
  role   = aws_iam_role.this.name
  name   = "${var.symbol.prefix}-kb-rds"
  policy = data.aws_iam_policy_document.rds.json
}


data "aws_iam_policy_document" "rds" {
  statement {
    effect    = "Allow"
    actions   = ["rds:DescribeDBClusters", "rds-data:BatchExecuteStatement", "rds-data:ExecuteStatement"]
    resources = [var.rds_cluster.arn]
  }
}

# 3. データソース

resource "aws_iam_role_policy" "datasource" {
  role   = aws_iam_role.this.name
  name   = "${var.symbol.prefix}-kb-datasource"
  policy = data.aws_iam_policy_document.datasource.json
}


data "aws_iam_policy_document" "datasource" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
    ]
    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*",
    ]
  }
}


# 4. Secret Managerに対するアクセス件

resource "aws_iam_role_policy" "user" {
  role   = aws_iam_role.this.name
  name   = "${var.symbol.prefix}-kb-user"
  policy = data.aws_iam_policy_document.user.json
}


data "aws_iam_policy_document" "user" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = [
      var.rds_user_secret.arn
    ]
  }
}
