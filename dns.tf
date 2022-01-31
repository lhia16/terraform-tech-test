# My own hosted zone
data "aws_route53_zone" "selected" {
  name         = "lhiagregg.com."
  private_zone = false
}

# AWS hosted zone that they run ELB service out of 
data "aws_elb_hosted_zone_id" "main" {}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "and-test.lhiagregg.com"
  type    = "A"

  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = data.aws_elb_hosted_zone_id.main.id
    evaluate_target_health = true
  }
}

