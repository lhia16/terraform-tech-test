module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 3.0"

  domain_name  = "and-test.lhiagregg.com"
  zone_id      = "Z054379726MPVPTS7ESA1"

  subject_alternative_names = [
    "*.and-test.lhiagregg.com"
    
  ]

  wait_for_validation = true

  tags = {
    Name = "and-test.lhiagregg.com"
  }
}