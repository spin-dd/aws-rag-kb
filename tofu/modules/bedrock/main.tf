
# ナレッジベース
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrockagent_knowledge_base
# https://dev.classmethod.jp/articles/create-knowledge-bases-for-amazon-bedrock-via-terraform/

resource "aws_bedrockagent_knowledge_base" "this" {
  name     = "${var.symbol.prefix}-kb"
  role_arn = aws_iam_role.this.arn
  #
  knowledge_base_configuration {
    vector_knowledge_base_configuration {
      embedding_model_arn = var.embedding_model_arn
    }
    type = "VECTOR"
  }
  #  
  storage_configuration {
    type = "RDS"
    rds_configuration {
      credentials_secret_arn = var.rds_user_secret.arn
      resource_arn           = var.rds_cluster.arn
      database_name          = var.rds_cluster.database_name
      #
      table_name = var.rds_table_anme
      field_mapping {
        primary_key_field = var.field_mapping.primary_key_field
        vector_field      = var.field_mapping.vector_field
        text_field        = var.field_mapping.text_field
        metadata_field    = var.field_mapping.metadata_field
      }
    }
  }
}



# データソース
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrockagent_data_source

resource "aws_bedrockagent_data_source" "this" {
  knowledge_base_id = aws_bedrockagent_knowledge_base.this.id
  name              = "${var.symbol.prefix}-kb-datasource"
  #
  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn = aws_s3_bucket.this.arn
    }
  }
  data_deletion_policy = "RETAIN" # データソースを削除すると基になるすべてのデータを保持
  # https://docs.aws.amazon.com/ja_jp/bedrock/latest/userguide/knowledge-base-ds-manage.html
  # データソースの削除ポリシーが Delete に設定されている場合、設定またはベクトルストアへのアクセスに問題があるため、データソースが削除プロセスを完了できない可能性があります。
}
