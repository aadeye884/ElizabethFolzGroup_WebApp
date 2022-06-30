# Route 53 Hosted Zone
resource "aws_route53_zone" "elizabethfolzgroup_zone" {
  name          = var.domain_name
  force_destroy = true
}

# Route 53 A Record
resource "aws_route53_record" "ElizabethFolzGroup_Website" {
  zone_id = aws_route53_zone.elizabethfolzgroup_zone.zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = aws_lb.elizabethfolzgroup-elb.dns_name
    zone_id                = aws_lb.elizabethfolzgroup-elb.zone_id
    evaluate_target_health = false
  }
}