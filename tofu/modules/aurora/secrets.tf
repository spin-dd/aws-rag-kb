resource "aws_secretsmanager_secret" "user" {
  name        = "${var.symbol.prefix}-secrete-aurora-user"
  description = "database user secrets"
  tags        = {}
}
resource "aws_secretsmanager_secret" "master_user" {
  name        = "${var.symbol.prefix}-secrete-aurora-master_user"
  description = "database master user secrets"
  tags        = {}
}

resource "aws_secretsmanager_secret_version" "user" {
  secret_id     = aws_secretsmanager_secret.user.id
  secret_string = jsonencode(var.database.user)
}

resource "aws_secretsmanager_secret_version" "master_user" {
  secret_id     = aws_secretsmanager_secret.master_user.id
  secret_string = jsonencode(var.database.master_user)
}
