data "aws_iam_policy_document" "pod_identity_trust_relationship" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

# External Secrets Operator
resource "aws_iam_role" "external_secret_operator" {
  name               = "ExternalSecretsOperator"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_trust_relationship.json
}

resource "aws_iam_policy" "external_secret_operator_secrets_access" {
  policy = file("./argocd-apps/iam_policies/external_secrets_operator.json")
  name   = "ExternalSecretOperatorSecretsAccess"
}

resource "aws_iam_role_policy_attachment" "external_secret_operator" {
  policy_arn = aws_iam_policy.external_secret_operator_secrets_access.arn
  role       = aws_iam_role.external_secret_operator.name
}

resource "aws_iam_role_policy_attachment" "external_secret_operator_ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  role       = aws_iam_role.external_secret_operator.name
}

resource "aws_eks_pod_identity_association" "external_secret_operator" {
  cluster_name    = "big-data-on-eks"
  namespace       = "external-secrets"
  service_account = "external-secrets"
  role_arn        = aws_iam_role.external_secret_operator.arn
}

# Connect to the datalake: Kafka Connect and Trino
resource "aws_iam_role" "iceberg_access" {
  name               = "DatalakeIcebergAccess"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_trust_relationship.json
}

resource "aws_iam_policy" "iceberg_access" {
  policy = file("./argocd-apps/iam_policies/iceberg_access.json")
  name   = "DatalakeIcebergAccess"
}

resource "aws_iam_role_policy_attachment" "iceberg_access" {
  policy_arn = aws_iam_policy.iceberg_access.arn
  role       = aws_iam_role.iceberg_access.name
}

# Kafka Connect Iceberg Sync Connector
resource "aws_eks_pod_identity_association" "iceberg_kafka_connector" {
  cluster_name    = "big-data-on-eks"
  namespace       = "kafka"
  service_account = "main-kafka-connect-cluster-connect"
  role_arn        = aws_iam_role.iceberg_access.arn
}

# Trino
resource "aws_eks_pod_identity_association" "iceberg_trino" {
  cluster_name    = "big-data-on-eks"
  namespace       = "trino"
  service_account = "trino"
  role_arn        = aws_iam_role.iceberg_access.arn
}

# Airflow
resource "aws_eks_pod_identity_association" "airflow_secrets_manager" {
  cluster_name    = "big-data-on-eks"
  namespace       = "airflow"
  service_account = "airflow-scheduler"
  role_arn        = aws_iam_role.external_secret_operator.arn
}
