variable "eks_cluster_name" {
  description = "The EKS cluster name."
  type        = string
}

variable "eks_vpc_id" {
  description = "The EKS VPC ID."
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