# Trino cluster
resource "kubectl_manifest" "trino" {
  yaml_body = templatefile(
    "${path.module}/argocd_applications/trino.yaml", //templating the argo cd application file
    {
      values = replace(
        templatefile(
          "${path.module}/../apps/trino/trino_values.yaml", //templating the values file
          {
            tls_certificate_arn = var.tls_certificate_arn
            domain_name         = var.domain_name
            trino_client_secret = random_password.trino_secret.result
          }
      ), "\n", "\n        ") // adding identation to yaml files
    }
  )

  depends_on = [
    kubectl_manifest.opa
    , kubectl_manifest.external_secrets_operator
    , null_resource.wait_for_keycloak
  ]
}

# Strimzi Operator
resource "kubectl_manifest" "strimzi_operator" {
  yaml_body = templatefile(
    "${path.module}/argocd_applications/strimzi_operator.yaml", //templating the argo cd application file
    {
      values = file("${path.module}/../apps/kafka/strimzi_operator_values.yaml")
    }
  )

  depends_on = [
    kubectl_manifest.opa
    , kubectl_manifest.external_secrets_operator
  ]
}

# Kafka Cluster
resource "kubectl_manifest" "kafka_cluster" {
  yaml_body = file("${path.module}/argocd_applications/kafka_cluster.yaml")

  depends_on = [kubectl_manifest.strimzi_operator]
}

# Kafka Connect Cluster
resource "kubectl_manifest" "kafka_connect_cluster" {
  yaml_body = file("${path.module}/argocd_applications/kafka_connect_cluster.yaml")

  depends_on = [kubectl_manifest.kafka_cluster]
}

# Kafka Connect Connectors
resource "kubectl_manifest" "kafka_connect_connectors" {
  yaml_body = file("${path.module}/argocd_applications/kafka_connect_connectors.yaml")

  depends_on = [kubectl_manifest.kafka_connect_cluster]
}

# Airflow

resource "random_password" "airflow_fernet_key" {
  length  = 32
  special = false
}

resource "kubectl_manifest" "airflow" {
  yaml_body = templatefile(
    "${path.module}/argocd_applications/airflow.yaml", //templating the argo cd application file
    {
      values = replace(
        templatefile(
          "${path.module}/../apps/airflow/airflow_values.yaml", //templating the values file
          {
            tls_certificate_arn = var.tls_certificate_arn
            domain_name         = var.domain_name
            airflow_fernet_key = random_password.airflow_fernet_key.result
          }
      ), "\n", "\n        ") // adding identation to yaml files
    }
  )

  depends_on = [
    kubectl_manifest.trino
  ]
}

# Superset
resource "kubectl_manifest" "superset" {
  yaml_body = templatefile(
    "${path.module}/argocd_applications/superset.yaml", //templating the argo cd application file
    {
      values = replace(
        templatefile(
          "${path.module}/../apps/superset/superset_values.yaml", //templating the values file
          {
            tls_certificate_arn = var.tls_certificate_arn
            domain_name         = var.domain_name
            keycloak_client_secret = random_password.superset_secret.result
          }
      ), "\n", "\n        ") // adding identation to yaml files
    }
  )

  depends_on = [
    kubectl_manifest.trino
    , null_resource.wait_for_keycloak
  ]
}