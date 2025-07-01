# This resource is needed to wait keycloak to create the Ingress
# and the AWS Load Balancer Controller to starting the load balancer creation.
# Then, we'll be able to get the load balancer DNS to configure the Route 53 record.
resource "time_sleep" "wait_30_seconds" {
  depends_on = [kubectl_manifest.keycloak]

  create_duration = "30s"
}

data "aws_lb" "default_alb" {
  tags = {
    "ingress.k8s.aws/stack" = "default"
  }

  depends_on = [time_sleep.wait_30_seconds]
}

data "aws_route53_zone" "deploy_zone" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "default_route" {
  zone_id = data.aws_route53_zone.deploy_zone.zone_id
  name    = "*.${var.domain_name}"
  type    = "CNAME"
  ttl     = "300"
  records = [data.aws_lb.default_alb.dns_name]
}