module "label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.3.3"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
  delimiter  = "${var.delimiter}"
  attributes = "${var.attributes}"
  tags       = "${var.tags}"
  enabled    = "${var.enabled}"
}

data "aws_region" "default" {}

resource "aws_route53_zone" "default" {
  count  = "${var.enabled == "true" ? 1 : 0}"
  name   = "${var.zone_name}"
  vpc    = "${var.vpc_id}"
  tags   = "${module.label.tags}"
}

resource "aws_route53_record" "ns" {
  count   = "${var.enabled == "true" ? 1 : 0}"
  zone_id = "${join("", aws_route53_zone.default.*.id)}"
  name    = "${var.zone_name}"
  type    = "NS"
  ttl     = "60"

  records = [
    "${aws_route53_zone.default.name_servers.0}",
    "${aws_route53_zone.default.name_servers.1}",
    "${aws_route53_zone.default.name_servers.2}",
    "${aws_route53_zone.default.name_servers.3}",
  ]
}

resource "aws_route53_record" "soa" {
  count           = "${var.enabled == "true" ? 1 : 0}"
  allow_overwrite = true
  zone_id         = "${join("", aws_route53_zone.default.*.id)}"
  name            = "${join("", aws_route53_zone.default.*.name)}"
  type            = "SOA"
  ttl             = "30"

  records = [
    "${aws_route53_zone.default.name_servers.0}. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400",
  ]
}
