output "ElizabethFolzGroup_WebApp_public_ip" {
  value = aws_instance.ElizabethFolzGroup_WebApp
}

output "ElizabethFolzGroup_db_endpoint" {
  value = aws_db_instance.elizabethfolzgroupdb.endpoint
}

output "name_servers" {
  value = aws_route53_record.ElizabethFolzGroup_Website
}

output "elizabethfolzgroup-elb_dns" {
  value = aws_lb.elizabethfolzgroup-elb.dns_name
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.elizabethfolzgroup_distribution.domain_name
}
