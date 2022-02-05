provider "helm" {
  kubernetes {
    config_path = ".kube/config"
  }
}

provider "aws" {
  region  = "us-east-2"
  profile = "default"
}