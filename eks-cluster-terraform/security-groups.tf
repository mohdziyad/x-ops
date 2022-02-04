
resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = -1

    cidr_blocks = [
      data.aws_vpc.vpc.cidr_block
    ]
  }
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = -1

    cidr_blocks = [
      data.aws_vpc.vpc.cidr_block
    ]
  }
}
