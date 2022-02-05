################################ EKS Cluster with 2 worker nodes and OIDC provider #############################
################################################################################################################

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.24.0"
  cluster_name    = "x-ops-eks-2022"
  cluster_version = "1.20"
  subnets         = [data.aws_subnet.private_2a.id, data.aws_subnet.private_2b.id, data.aws_subnet.private_2c.id]
  vpc_id          = data.aws_vpc.vpc.id
  enable_irsa     = true

  workers_group_defaults = {
    root_volume_type = "gp2"
  }

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t3.medium"
      additional_userdata           = "echo xops"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
      asg_desired_capacity          = 2
    },
  ]
}

resource "aws_eks_identity_provider_config" "this" {
  cluster_name = module.eks.cluster_id

  oidc {
    client_id                     = "sts.amazonaws.com"
    issuer_url                    = module.eks.cluster_oidc_issuer_url
    identity_provider_config_name = "oidc_xops"
  }
}

########################### ALB ingress role and policies for the ingress controller service account ##############
###################################################################################################################
module "alb_ingress" {
  source           = "./modules/terraform-aws-iam"
  cluster_name     = module.eks.cluster_id
  role_name        = "alb-ingress"
  service_accounts = ["kube-system/alb-ingress-controller"]
  policies         = [data.aws_iam_policy_document.alb_ingress.json]
}