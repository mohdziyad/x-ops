data "aws_ssm_parameter" "dbpassword" {
  name = "dbpwd"
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4"

  name   = "rds-sg"
  vpc_id = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]
}

# RDS Module

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
  vpc_security_group_ids = [module.security_group.security_group_id]

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

output "rds_endpoint" {
  description = "RDS endpoint to be used to load data to db"
  value       = module.db.db_instance_address
}