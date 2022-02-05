data "aws_availability_zones" "available" {}

data "aws_ssm_parameter" "dbpassword" {
  name = "dbpwd"
}