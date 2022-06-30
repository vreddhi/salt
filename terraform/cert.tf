resource "aws_acm_certificate" "securecodezone_cert" {
  domain_name       = "securecodezone.com"
  validation_method = "DNS"
}

data "aws_route53_zone" "securecodezone_zone" {
  name         = "securecodezone.com"
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

resource "aws_acm_certificate_validation" "securecodezone_cert_valid" {
  certificate_arn         = aws_acm_certificate.securecodezone_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.securecodezone_records : record.fqdn]
}

resource "aws_lb" "front_end" {
  name               = "front-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.webapp-securitygroup.id]
  subnets            = [aws_subnet.public-subnet-1.id, aws_subnet.public-subnet-2.id]

  #enable_deletion_protection = true

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "alb_tgt_group" {
  name        = "alb-targetgp"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.private-cloud.id
}

resource "aws_lb_target_group_attachment" "alb_tgtgp_assign" {
  target_group_arn = aws_lb_target_group.alb_tgt_group.arn
  target_id        = aws_instance.webapp-instance.id
  port             = 80
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.front_end.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.securecodezone_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tgt_group.arn
  }
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