########################################## Security group for the ingress ALB #################################
###############################################################################################################

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