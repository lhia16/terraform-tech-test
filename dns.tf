# My own hosted zone
data "aws_route53_zone" "selected" {
  name         = var.r53_hosted_zone
  private_zone = false
}

# AWS hosted zone that they run ELB service out of 
data "aws_elb_hosted_zone_id" "main" {}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = data.aws_elb_hosted_zone_id.main.id
    evaluate_target_health = true
  }
}

