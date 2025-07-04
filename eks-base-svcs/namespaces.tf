locals {
  namespaces = {
    argocd           = "argocd"
    external-secrets = "external-secrets"
    kafka            = "kafka"
    opa              = "opa"
    trino            = "trino"
    superset         = "superset"
    keycloak         = "keycloak"
  }
}

resource "kubectl_manifest" "namespaces" {
  for_each  = local.namespaces
  yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata:
  name: ${each.value}
YAML
}