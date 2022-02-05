variable "region" {
  default     = "us-east-2"
  description = "AWS region"
}

variable "pem_key" {
  description = "pem key file used for ssh into bastion host as well as for provisioner authentication to copy data file"
}