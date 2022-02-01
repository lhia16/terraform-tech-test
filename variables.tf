###################################
# Generic Variables
###################################

variable "project_name" {
  description = "Name of project, to be re-used"
  type        = string
  default     = "and-tech-test"
}

###################################
# VPC Variables
###################################

variable "vpc_name" {
  description = "Name of VPC"
  type        = string
  default     = "main-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_azs" {
  description = "Availability zones for VPC"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b"]
}

variable "vpc_private_subnets" {
  description = "Private subnets for VPC"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "vpc_public_subnets" {
  description = "Public subnets for VPC"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "vpc_enable_nat_gateway" {
  description = "Enable NAT gateway for VPC"
  type        = bool
  default     = true
}

variable "vpc_tags" {
  description = "Tags to apply to resources created by VPC module"
  type        = map(string)
  default = {
    Terraform   = "true"
    Environment = "dev"
  }
}

###################################
# ASG Variables
###################################

variable "vpc_enable_nat_gateway" {
  description = "Enable NAT gateway for VPC"
  type        = bool
  default     = true
}


###################################
# LB Variables
###################################

variable "lb_prefix" {
  description = "Prefix for lb target group"
  type        = string
  default     = "andtechtest-"
}

###################################
# Miscellaneous Variables
###################################
variable "r53_hosted_zone" {
  description = "Prexisting hosted zone - DNS records will be added to"
  type        = string
  default     = "lhiagregg.com"
}


variable "domain_name" {
  description = "Domain name created for this test"
  type        = string
  default     = "and-test.lhiagregg.com"
}