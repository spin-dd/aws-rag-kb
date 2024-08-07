output "repos" {
  sensitive = false
  value     = aws_ecr_repository.this
}
