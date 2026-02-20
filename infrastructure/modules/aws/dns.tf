# ACM DNS validation records in Cloudflare
resource "cloudflare_dns_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      value = dvo.resource_record_value
      type  = dvo.resource_record_type
    }
  }

  zone_id = var.cloudflare_zone_id
  name    = each.value.name
  type    = each.value.type
  content = each.value.value
  ttl     = 60
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in cloudflare_dns_record.acm_validation : record.name]
}

# CNAME pointing quest.aws.shart.cloud to the ALB
resource "cloudflare_dns_record" "quest" {
  zone_id = var.cloudflare_zone_id
  name    = "quest.aws"
  type    = "CNAME"
  content = aws_lb.this.dns_name
  ttl     = 1
  proxied = false
}
