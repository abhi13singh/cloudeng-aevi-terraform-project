# get hosted zone details
data "aws_route53_zone" "hosted_zone" {
  name = var.domain_name
}

# create records set in route 53 to enable access to the dockerized app
resource "aws_route53_record" "site_domain" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = var.record_name
  type    = "A"

  alias {
    name                   = module.alb.dns_name
    zone_id                = module.alb.zone_id
    evaluate_target_health = true
  }
}