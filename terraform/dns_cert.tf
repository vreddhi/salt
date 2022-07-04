#Create a certificate for domain name
resource "aws_acm_certificate" "securecodezone_cert" {
  domain_name       = "${var.domain-name}"
  validation_method = "DNS"
}

#Get a reference to the DNS zone
data "aws_route53_zone" "securecodezone_zone" {
  name         = "${var.domain-name}"
  private_zone = false
}


#Create the validation DNS records
resource "aws_route53_record" "securecodezone_records" {
  for_each = {
    for dvo in aws_acm_certificate.securecodezone_cert.domain_validation_options : dvo.domain_name => {
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
  zone_id         = data.aws_route53_zone.securecodezone_zone.zone_id
}


#Create a CNAME record for www to the ALB
resource "aws_route53_record" "securecodezone_cname_top" {
  allow_overwrite = true
  name            = var.sub-domain-name
  records         = [aws_lb.front_end.dns_name]
  ttl             = 60
  type            = "CNAME"
  zone_id         = data.aws_route53_zone.securecodezone_zone.zone_id
}

#Create a CNAME record for top level to the ALB
resource "aws_route53_record" "securecodezone_cname_sub" {
  allow_overwrite = true
  name            = var.domain-name
  type            = "A"
  zone_id         = data.aws_route53_zone.securecodezone_zone.zone_id

  alias {
    name                   = aws_lb.front_end.dns_name
    zone_id                = aws_lb.front_end.zone_id
    evaluate_target_health = false    
  }
}