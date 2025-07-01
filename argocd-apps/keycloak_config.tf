resource "null_resource" "wait_for_keycloak" {
  depends_on = [kubectl_manifest.keycloak]

  provisioner "local-exec" {
    command = <<EOT
    echo "Cleaning local DNS cache..."
    dscacheutil -flushcache
    killall -HUP mDNSResponder || true
    for i in {1..30}; do
      echo "Waiting for Keycloak to be ready..."
      if curl -ksf https://keycloak.${var.domain_name}/realms/master; then
        echo "Keycloak is up!"
        exit 0
      fi
      sleep 10
    done
    echo "Keycloak did not become ready in time"
    exit 1
    EOT
  }
}

resource "keycloak_realm" "data_platform" {
  realm        = "data_platform"
  enabled      = true
  display_name = "Data Platform Realm"

  depends_on = [null_resource.wait_for_keycloak]
}

# Getting the IPD values
data "aws_secretsmanager_secret" "idp_values" {
  name = var.idp_config_secret
}

# Busca a versão atual da secret
data "aws_secretsmanager_secret_version" "idp_values" {
  secret_id = data.aws_secretsmanager_secret.idp_values.id
}

locals {
  idp_values = jsondecode(data.aws_secretsmanager_secret_version.idp_values.secret_string)
}

# Setting the External IDP
resource "keycloak_oidc_identity_provider" "external_idp" {
  realm                     = keycloak_realm.data_platform.id
  alias                     = local.idp_values.idp_alias
  display_name              = local.idp_values.display_name
  client_id                 = local.idp_values.client_id
  client_secret             = local.idp_values.client_secret
  authorization_url         = local.idp_values.authorization_url
  token_url                 = local.idp_values.token_url
  issuer                    = local.idp_values.issuer
  default_scopes            = "openid email profile"
  store_token               = true
  trust_email               = true
  sync_mode                 = "FORCE"
  first_broker_login_flow_alias = "first broker login"
}

# Setting the email as preferred_username
resource "keycloak_custom_identity_provider_mapper" "email" {
  realm                    = keycloak_realm.data_platform.id
  identity_provider_alias  = keycloak_oidc_identity_provider.external_idp.alias
  name                     = "email"
  identity_provider_mapper = "oidc-user-attribute-idp-mapper"

  extra_config = {
    "claim"          = "email"
    "user.attribute" = "email"
  }
}

resource "keycloak_custom_identity_provider_mapper" "preferred_username" {
  realm                    = keycloak_realm.data_platform.id
  identity_provider_alias  = keycloak_oidc_identity_provider.external_idp.alias
  name                     = "preferred_username"
  identity_provider_mapper = "oidc-user-attribute-idp-mapper"

  extra_config = {
    "claim"          = "email"
    "user.attribute" = "preferred_username"
  }
}

# Setting the Superset client
resource "random_password" "superset_secret" {
  length  = 32
  special = false
}

resource "keycloak_openid_client" "superset" {
  realm_id            = keycloak_realm.data_platform.id
  client_id           = "superset"
  name                = "Superset"
  enabled             = true
  client_secret       = random_password.superset_secret.result
  access_type         = "CONFIDENTIAL"
  standard_flow_enabled  = true
  direct_access_grants_enabled = true
  valid_redirect_uris = [
    "https://superset.${var.domain_name}/*"
  ]
  web_origins         = ["+"]
  root_url  = "https://superset.${var.domain_name}"
  base_url  = "/login/"
}

resource "keycloak_openid_user_attribute_protocol_mapper" "superset_email" {
  name            = "email"
  realm_id        = keycloak_realm.data_platform.id
  client_id       = keycloak_openid_client.superset.id
  user_attribute  = "email"
  claim_name      = "email"
  claim_value_type = "String"
  add_to_id_token = true
  add_to_access_token = true
  add_to_userinfo = true
}

resource "keycloak_openid_user_attribute_protocol_mapper" "superset_username" {
  name            = "preferred_username"
  realm_id        = keycloak_realm.data_platform.id
  client_id       = keycloak_openid_client.superset.id
  user_attribute  = "email"
  claim_name      = "preferred_username"
  claim_value_type = "String"
  add_to_id_token = true
  add_to_access_token = true
  add_to_userinfo = true
}

# Setting the Trino client
resource "random_password" "trino_secret" {
  length  = 32
  special = false
}

resource "keycloak_openid_client" "trino" {
  realm_id            = keycloak_realm.data_platform.id
  client_id           = "trino"
  name                = "Trino"
  enabled             = true
  client_secret       = random_password.trino_secret.result
  access_type         = "CONFIDENTIAL"
  standard_flow_enabled  = true
  direct_access_grants_enabled = true
  valid_redirect_uris = [
    "https://trino.${var.domain_name}/oauth2/callback",
    "https://trino.${var.domain_name}/ui/logout/logout.html"
  ]
  web_origins         = ["+"]
  root_url  = "https://trino.${var.domain_name}"
  base_url  = "/"
}

resource "keycloak_openid_user_attribute_protocol_mapper" "trino_email" {
  name             = "email"
  realm_id         = keycloak_realm.data_platform.id
  client_id        = keycloak_openid_client.trino.id
  user_attribute   = "email"
  claim_name       = "email"
  claim_value_type = "String"
  add_to_id_token  = true
  add_to_access_token = true
  add_to_userinfo  = true
}

resource "keycloak_openid_user_attribute_protocol_mapper" "trino_username" {
  name             = "preferred_username"
  realm_id         = keycloak_realm.data_platform.id
  client_id        = keycloak_openid_client.trino.id
  user_attribute   = "email"
  claim_name       = "preferred_username"
  claim_value_type = "String"
  add_to_id_token  = true
  add_to_access_token = true
  add_to_userinfo  = true
}