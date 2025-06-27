terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    keycloak = {
      source  = "keycloak/keycloak"
      version = "5.2.0"
    }
  }
}