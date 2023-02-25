data "aws_route53_zone" "main" {
  name = "yourdevopsmentor.net"
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "www.${data.aws_route53_zone.main.name}"
  type    = "CNAME"
  ttl     = "300"
  records = [module.loadbalancer.lb_dns_name]
}
