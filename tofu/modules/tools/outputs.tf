output "lambda" {
  sensitive = false
  value     = aws_lambda_function.this
}
