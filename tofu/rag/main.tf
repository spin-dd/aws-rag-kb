terraform {
  backend "s3" {
    # backend は variable評価前に実行されるので TF_VAR_ 環境変数を参照することになる
    region         = var.admin_region
    bucket         = "${var.service}-admin-state"
    key            = "terraform/${var.env}/terraform.tfstate"
    dynamodb_table = "${var.service}-admin-statedb-${var.env}"
  }
}

provider "aws" {
  region = local.region # AWS リージョン
}


# VPC ネットワーク関連の定義
module "vpc" {
  source = "../modules/vpc"
  symbol = local.symbol
  region = local.region
  #
}

# ecr for lambda functions
module "ecr" {
  source = "../modules/ecr"
  symbol = local.symbol
  #
}

# aws tools

module "tools" {
  source = "../modules/tools"
  symbol = local.symbol
  #
  ecr = module.ecr.repos.tools
}

# aurora cluster
module "aurora" {
  source = "../modules/aurora"
  symbol = local.symbol
  region = local.region
  #
  subnet_group_name = module.vpc.private_subnet_group_name
  cluster_zones     = module.vpc.private_zones
  instance_zone     = module.vpc.private_zones[0]
  database          = local.database
}

# bedrock
module "bedrock" {
  source = "../modules/bedrock"
  symbol = local.symbol
  region = local.region
  #
  rds_cluster     = module.aurora.cluster
  rds_user_secret = module.aurora.user_secret
  rds_table_anme  = module.aurora.table_name
  field_mapping   = local.field_mapping
}


# api gateway
module "apigw" {
  source = "../modules/apigw"
  symbol = local.symbol
  #
  kb          = module.bedrock.kb
  domain_name = var.domain_name
  ecr         = module.ecr.repos.kb
}
