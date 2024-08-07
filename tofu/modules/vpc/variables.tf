variable "symbol" {}
variable "region" {}
#

variable "cidr" {
  default = "10.0.0.0/16"
}

# cidrsubnet(): https://www.terraform.io/docs/language/functions/cidrsubnet.html
locals {
  subnet_pri = {
    "a" = {
      cidr = cidrsubnet(var.cidr, 8, 11) # 10.0.11.0/24
      zone = "${var.region}a"
    }
    "c" = {
      cidr = cidrsubnet(var.cidr, 8, 12) # 10.0.12.0/24
      zone = "${var.region}c"
    }
  }
  subnet_pub = {
    "a" = {
      cidr = cidrsubnet(var.cidr, 8, 21) # 10.0.21.0/24
      zone = "${var.region}a"
    }
    "c" = {
      cidr = cidrsubnet(var.cidr, 8, 22) # 10.0.22.0/24
      zone = "${var.region}c"
    }
  }

}
