locals {
  argocd_namespace = "cicd"
}

resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = local.argocd_namespace
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "7.6.12"

  values = [
    templatefile(
        "${path.module}/argocd-templates/argocd_values.yaml",
        {
            argocd_global_domain = "argocd.${var.domain_name}"
        }
    )
  ]
}

# Route 53 record to ArgoCD ingress
data "kubernetes_ingress_v1" "argocd_ingress" {
  metadata {
    name = "argocd-server"
    namespace = local.argocd_namespace
  }
  depends_on = [helm_release.argocd]
}

data "aws_route53_zone" "deploy_zone" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "default_route" {
  zone_id = data.aws_route53_zone.deploy_zone.zone_id
  name    = "argocd.${var.domain_name}"
  type    = "CNAME"
  ttl     = "300"
  records = [data.kubernetes_ingress_v1.argocd_ingress.status.0.load_balancer.0.ingress.0.hostname]
}