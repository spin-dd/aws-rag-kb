output "cluster" {
  sensitive = false
  value     = aws_rds_cluster.this
}

output "user_secret" {
  sensitive = false
  value     = aws_secretsmanager_secret_version.user
}

output "master_user_secret" {
  sensitive = false
  value     = aws_secretsmanager_secret_version.master_user
}

output "table_name" {
  sensitive = false
  value     = local.table_name
}
