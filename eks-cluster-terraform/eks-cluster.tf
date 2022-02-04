provider "aws" {
  region  = "us-east-2"
  profile = "default"
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.24.0"
  cluster_name    = "x-ops-eks-2022"
  cluster_version = "1.20"
  subnets         = [data.aws_subnet.private_2a.id, data.aws_subnet.private_2b.id, data.aws_subnet.private_2c.id]
  vpc_id          = data.aws_vpc.vpc.id
  enable_irsa     = true

  workers_group_defaults = {
    root_volume_type = "gp2"
  }

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t3.medium"
      additional_userdata           = "echo xops"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
      asg_desired_capacity          = 2
    },
  ]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

data "aws_subnet" "private_2a" {
  filter {
    name   = "tag:Name"
    values = ["x-ops-vpc-private-us-east-2a"]
  }
}

data "aws_subnet" "private_2b" {
  filter {
    name   = "tag:Name"
    values = ["x-ops-vpc-private-us-east-2b"]
  }
}

data "aws_subnet" "private_2c" {
  filter {
    name   = "tag:Name"
    values = ["x-ops-vpc-private-us-east-2c"]
  }
}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["x-ops-vpc"]
  }
}