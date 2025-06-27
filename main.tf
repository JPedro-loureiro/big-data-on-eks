module "eks_base_infra" {
  source      = "./eks-base-infra"
  aws_region  = var.aws_region
  aws_profile = var.aws_profile
}

module "eks_base_svcs" {
  source = "./eks-base-svcs"

  # EKS variables
  eks_cluster_name = module.eks_base_infra.eks_cluster_name

  # VPC variables
  eks_vpc_id = module.eks_base_infra.eks_vpc_id

  # Route53 variables
  domain_name = var.domain_name

  argocd_version = var.argocd_version

  lb_controller_version = var.lb_controller_version

  depends_on = [module.eks_base_infra]
}

module "argocd_applications" {
  source = "./argocd-apps"

  # AWS Certificate Manager variables
  tls_certificate_arn = module.eks_base_svcs.tls_certificate_arn

  # Route53 variables
  domain_name = var.domain_name

  # IDP variables
  idp_config_secret = var.idp_config_secret

  depends_on = [module.eks_base_svcs]
}