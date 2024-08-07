output "kb" {
  sensitive = false
  value     = aws_bedrockagent_knowledge_base.this
}

output "ds" {
  sensitive = false
  value     = aws_bedrockagent_data_source.this
}

output "s3" {
  sensitive = false
  value     = aws_s3_bucket.this
}
