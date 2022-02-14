terraform {
  backend "s3" {
    bucket         = "x-ops-tf-states-002"
    region         = "us-east-2"
    dynamodb_table = "x-ops-tf-states-002"
    key            = "database-infra-terraform.tfstate"
  }
}