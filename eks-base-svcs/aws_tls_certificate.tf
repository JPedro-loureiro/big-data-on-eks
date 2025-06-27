resource "aws_acm_certificate" "bigdataoneks" {
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"
}

data "aws_route53_zone" "bigdataoneks" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "bigdataoneks_tls_certificate" {
  for_each = {
    for dvo in aws_acm_certificate.bigdataoneks.domain_validation_options : dvo.domain_name => {
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
  zone_id         = data.aws_route53_zone.bigdataoneks.zone_id
}

resource "aws_acm_certificate_validation" "bigdataoneks_tls_certificate_validation" {
  certificate_arn         = aws_acm_certificate.bigdataoneks.arn
  validation_record_fqdns = [for record in aws_route53_record.bigdataoneks_tls_certificate : record.fqdn]
}