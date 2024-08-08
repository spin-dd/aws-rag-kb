provider "aws" {
  alias  = "oregon"
  region = "us-west-2"
}

## Zone
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone
data "aws_route53_zone" "kx" {
  for_each = local.domain_names
  #
  name         = each.value
  private_zone = false
}


# 証明書
resource "aws_acm_certificate" "kx" {
  provider                  = aws.oregon
  domain_name               = local.cert_subject
  subject_alternative_names = local.cert_subject_altnames
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

# ドメイン名検証 

resource "aws_route53_record" "kx" {
  for_each = {
    for dvo in aws_acm_certificate.kx.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = local.zones[each.key].id
}


# Certificate Validateion
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation

resource "aws_acm_certificate_validation" "kx" {
  certificate_arn         = aws_acm_certificate.kx.arn
  validation_record_fqdns = [for record in aws_route53_record.kx : record.fqdn]
  provider                = aws.oregon
}
