output "AURORA_CLUSTER_NAME" {
  value = module.aurora.cluster.cluster_identifier
}

output "AURORA_CLUSTER_ARN" {
  value = module.aurora.cluster.arn
}

output "AURORA_MASTER_USER_SECERT_ARN" {
  value = module.aurora.master_user_secret.arn
}

output "AURORA_USER_SECERT_ARN" {
  value = module.aurora.user_secret.arn
}

output "DATASOURCE_BUCKET" {
  value = module.bedrock.s3.id
}

output "BEDROCK_KB_ID" {
  value = module.bedrock.kb.id
}
output "BEDROCK_DS_ID" {
  value = module.bedrock.ds.data_source_id
}
