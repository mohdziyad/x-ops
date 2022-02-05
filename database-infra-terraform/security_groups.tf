####################################### RDS Security group with 5432 port inbound from VPC #################
############################################################################################################

module "rds_security_group" {
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

#################################### DB Agent security group with SSH inbound ###################################
#####################################################################################################################

module "db_agent_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4"

  name   = "db-agent-sg"
  vpc_id = module.vpc.vpc_id

  # ingress
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp"]
  egress_rules        = ["all-all"]
}