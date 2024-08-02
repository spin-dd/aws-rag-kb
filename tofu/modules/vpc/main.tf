# VPC
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc

resource "aws_vpc" "this" {
  cidr_block           = var.cidr # 10.0.0.0/16
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.symbol.prefix}-vpc"
  }
}



# Subnet (サブネット)
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet



# プライベート
resource "aws_subnet" "private" {
  for_each = local.subnet_pri
  #
  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.value.zone
  cidr_block              = each.value.cidr
  map_public_ip_on_launch = false

  tags = {
    "Name" = "${var.symbol.prefix}-subnet-private-${each.key}"
  }
}

# パブリック
resource "aws_subnet" "public" {
  for_each = local.subnet_pub
  #
  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.value.zone
  cidr_block              = each.value.cidr
  map_public_ip_on_launch = true

  tags = {
    "Name" = "${var.symbol.prefix}-subnet-public-${each.key}"
  }
}


# サブネットグループ
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group
# プライベート
resource "aws_db_subnet_group" "private" {
  name = "${var.symbol.prefix}-subnetgroup-private"

  subnet_ids = [for i in aws_subnet.private : i.id]
}


# ルーティングテーブル
# Routing Table(rt)
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.symbol.prefix}-rt-private"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.symbol.prefix}-rt-public"
  }
}

# ルートテーブル-サブネット割り当て
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public
  #
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private
  #
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}


# Intener Gateway (インターネットゲートウェイ)
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.symbol.prefix}-igw"
  }
}

# ルート
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route
resource "aws_route" "internet" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
  route_table_id         = aws_route_table.public.id
}

