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