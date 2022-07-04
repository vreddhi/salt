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
      Project = "webapp"
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

#Listener on port 80 to redirect to 443
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.front_end.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}