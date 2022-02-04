resource "helm_release" "alb_ingress_controller_deploy" {
  name    = "xeneta-alb-ingress-deploy"
  chart   = "../charts/k8s-alb-ingress-controller/"
  version = "0.1.0"

  values = [
    "${file("alb_ingress_controller_custom_values.yml")}"
  ]
  set {
    name  = "serviceAccount.iamrole"
    value = data.aws_iam_role.ingress_role.arn
  }
  set {
    name  = "deployIngress.clusterName"
    value = "x-ops-eks-2022"
  }
}

module "alb_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4"

  name   = "alb-sg"
  vpc_id = data.aws_vpc.vpc.id

  # ingress
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp"]
  egress_rules        = ["all-all"]
}


resource "helm_release" "xeneta_rates_app_deploy" {
  name    = "xeneta-rates-app-deploy"
  chart   = "../charts/xeneta-rates/"
  version = "0.1.0"

  values = [
    "${file("alb_ingress_controller_custom_values.yml")}"
  ]
  set {
    name  = "dbService.rdsEndPoint"
    value = data.aws_db_instance.database.address
  }
  set {
    name  = "deployment.containers.image"
    value = "${data.aws_caller_identity.current.id}.dkr.ecr.us-east-2.amazonaws.com/x-ops-repo:1.0"
  }
  set {
    name  = "ingress.albSg"
    value = module.alb_security_group.security_group_id
  }
  /*
  set {
    name  = "ingress.albSg"
    value = data.aws_security_group.public_sg.id
  }
  */
}

#####################################data sources################################
#################################################################################
data "aws_iam_role" "ingress_role" {
  name     = "x-ops-eks-2022-alb-ingress"
  provider = aws
}

data "aws_db_instance" "database" {
  db_instance_identifier = "x-ops-rds"
  provider               = aws
}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["x-ops-vpc"]
  }

data "aws_security_group" "public_sg" {
  filter {
    name   = "tag:Name"
    values = ["bastion-sg"]
  }
  provider = aws
}

data "aws_caller_identity" "current" {}

#########################provider#################
provider "aws" {
  region  = "us-east-2"
  profile = "default"
}