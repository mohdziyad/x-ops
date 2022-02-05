terraform {
  backend "s3" {
    bucket         = "x-ops-tf-states"
    region         = "us-east-2"
    dynamodb_table = "x-ops-tf-states"
    key            = "helm-terraform.tfstate"
  }
}