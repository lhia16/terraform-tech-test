module "ec2_instances" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "3.4.0"

  for_each = toset(["one", "two"])

  name = "instance-${each.key}"

  ami                    = "ami-00ae935ce6c2aa534"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  subnet_id              = module.vpc.public_subnets[0]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}