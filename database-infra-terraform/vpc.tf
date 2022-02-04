variable "region" {
  default     = "us-east-2"
  description = "AWS region"
}

provider "aws" {
  region  = var.region
  profile = "default"
}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = "x-ops-eks-2022"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "x-ops-vpc"
  cidr = "10.10.0.0/16"

  azs                  = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets      = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
  public_subnets       = ["10.10.11.0/24", "10.10.12.0/24", "10.10.13.0/24"]
  database_subnets     = ["10.10.21.0/24", "10.10.22.0/24", "10.10.23.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}
