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
