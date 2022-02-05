locals {
  cluster_name = "x-ops-eks-2022"
}

#########################  VPC with 3 Private, Public and DB (Private) subnets ##############################
#############################################################################################################

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


######################################### RDS Postgresql 13.5 DB #################################################
##################################################################################################################

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier           = "x-ops-rds"
  engine               = "postgres"
  engine_version       = "13.5"
  family               = "postgres13" # DB parameter group
  major_engine_version = "13"         # DB option group
  instance_class       = "db.t3.large"

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = false
  name                  = "rates"
  username              = "postgres"
  password              = data.aws_ssm_parameter.dbpassword.value
  port                  = 5432

  multi_az               = true
  subnet_ids             = module.vpc.database_subnets
  vpc_security_group_ids = [module.rds_security_group.security_group_id]

  enabled_cloudwatch_logs_exports = ["postgresql"]

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

  performance_insights_enabled = false
  create_monitoring_role       = false

  parameters = [
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]
}


################################# Bastion Host with psql13 client for loading data to Private DB ######################
#######################################################################################################################

resource "aws_instance" "bastion_host" {

  ami                         = "ami-0231217be14a6f3ba"
  instance_type               = "t2.micro"
  subnet_id                   = element(module.vpc.public_subnets, 0)
  vpc_security_group_ids      = [module.bastion_security_group.security_group_id]
  associate_public_ip_address = true
  user_data                   = file("bastion-userdata.sh")
  key_name                    = "xops"
  provisioner "file" {
    source      = "rates.sql"
    destination = "/tmp/rates.sql"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.pem_key)
      host        = self.public_dns
    }
  }
  tags = {
    "name" = "bastion-host"
  }

}

######################################## ECR Respository to store Docker image #############################
############################################################################################################

resource "aws_ecr_repository" "xops" {
  name                 = "x-ops-repo"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}