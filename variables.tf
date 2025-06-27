variable "aws_region" {
  description = "The AWS region."
  type        = string
}

variable "aws_profile" {
  description = "The AWS CLI profile name."
  type        = string
}

variable "domain_name" {
  description = "The route53 domain name to use for configure ingresses."
  type        = string
}

variable "argocd_version" {
  description = "The ArgoCD version."
  type        = string
}

variable "lb_controller_version" {
  description = "The AWS Load Balancer Controller version."
  type        = string
}

variable "idp_config_secret" {
  description = "The AWS Secrets Manager secret name storing the idp configuration to be used by Keycloak."
  type        = string
}