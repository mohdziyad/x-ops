################################# HELM deploy alb ingress controller chart ################################
###########################################################################################################

resource "helm_release" "alb_ingress_controller_deploy" {
  name    = "xeneta-alb-ingress-deploy"
  chart   = "../helm-charts/charts/k8s-alb-ingress-controller/"
  version = "0.1.0"

  values = [
    "${file("values.yml")}"
  ]
  set {
    name  = "serviceAccount.iamrole"
    value = data.aws_iam_role.ingress_role.arn
  }
  set {
    name  = "deployIngress.clusterName"
    value = "x-ops-eks-2022"
  }
}

#################################### HELM Deploy rates app chart #############################################
##############################################################################################################

resource "helm_release" "xeneta_rates_app_deploy" {
  name    = "xeneta-rates-app-deploy"
  chart   = "../helm-charts/charts/xeneta-rates/"
  version = "0.1.0"

  values = [
    "${file("values.yml")}"
  ]
  set {
    name  = "dbService.rdsEndPoint"
    value = data.aws_db_instance.database.address
  }
  set {
    name  = "deployment.containers.image"
    value = "${data.aws_caller_identity.current.id}.dkr.ecr.us-east-2.amazonaws.com/x-ops-repo:${var.image_tag}"
  }
  set {
    name  = "ingress.albSg"
    value = module.alb_security_group.security_group_id
  }
}