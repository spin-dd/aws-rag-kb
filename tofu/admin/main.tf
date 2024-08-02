provider "aws" {
  region = local.region # AWS リージョン
}

module "tfstate" {
  source = "../modules/tfstate"
  symbol = local.symbol
}
