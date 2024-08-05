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


