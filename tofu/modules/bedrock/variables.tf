variable "symbol" {}
variable "region" {}

variable "rds_cluster" {}
variable "rds_user_secret" {}
variable "rds_table_anme" {}
variable "field_mapping" {

}

variable "embedding_model_arn" {
  default = "arn:aws:bedrock:us-west-2::foundation-model/amazon.titan-embed-text-v1"
}
