data "aws_caller_identity" "current" {}

data "aws_db_instance" "database" {
  db_instance_identifier = "x-ops-rds"
  provider               = aws
}

data "aws_iam_role" "ingress_role" {
  name     = "x-ops-eks-2022-alb-ingress"
  provider = aws
}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["x-ops-vpc"]
  }
}

data "aws_security_group" "public_sg" {
  filter {
    name   = "tag:Name"
    values = ["db-agent-sg"]
  }
  provider = aws
}

