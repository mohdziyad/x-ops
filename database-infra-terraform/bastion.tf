module "bastion_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4"

  name   = "bastion-sg"
  vpc_id = module.vpc.vpc_id

  # ingress
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp"]
  egress_rules        = ["all-all"]
}

################################################################################
# EC2 Module
################################################################################

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

variable "pem_key" {}

output "ip" {
  value = aws_instance.bastion_host.public_ip
}