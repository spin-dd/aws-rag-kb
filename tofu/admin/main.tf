provider "aws" {
  region = local.region # AWS リージョン
}

module "tfstate" {
  source = "../modules/tfstate"
  symbol = local.symbol
  region = local.region
  envs   = local.envs # 管理対象環境
}
