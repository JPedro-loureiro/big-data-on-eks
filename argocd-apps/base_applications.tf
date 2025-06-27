# OPA Server
resource "kubectl_manifest" "opa" {
  yaml_body = file("${path.module}/argocd_applications/opa.yaml")

  depends_on = [kubectl_manifest.big_data_project]
}

# External Secrets Operator
resource "kubectl_manifest" "external_secrets_operator" {
  yaml_body = templatefile(
    "${path.module}/argocd_applications/external_secrets_operator.yaml", //templating the argo cd application file
    {
      values = replace(
        templatefile(
          "${path.module}/../apps/external_secrets_operator/external_secrets_operator_values.yaml", //templating the values file
          {
            tls_certificate_arn = var.tls_certificate_arn
            domain_name         = var.domain_name
          }
      ), "\n", "\n        ") // adding identation to yaml files
    }
  )

  depends_on = [kubectl_manifest.base_applications_project]
}

# This resource is needed to wait the ESO operator to create
# the CRDs, so we'll be able to create the secrets.
resource "time_sleep" "wait_eso_operator" {
  depends_on = [kubectl_manifest.external_secrets_operator]

  create_duration = "120s"
}

# External Secrets
resource "kubectl_manifest" "external_secrets" {
  yaml_body = file("${path.module}/argocd_applications/external_secrets.yaml")

  depends_on = [time_sleep.wait_eso_operator]
}

# Keycloak
resource "kubectl_manifest" "keycloak" {
  yaml_body = templatefile(
    "${path.module}/argocd_applications/keycloak.yaml", //templating the argo cd application file
    {
      values = replace(
        templatefile(
          "${path.module}/../apps/keycloak/keycloak_values.yaml", //templating the values file
          {
            tls_certificate_arn = var.tls_certificate_arn
            domain_name         = var.domain_name
          }
      ), "\n", "\n        ") // adding identation to yaml files
    }
  )
}