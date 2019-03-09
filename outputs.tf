output "zone_id" {
  value       = "${join("", aws_route53_zone.default.*.zone_id)}"
  description = "Route53 DNS Zone ID"
}

output "zone_name" {
  value       = "${replace(join("", aws_route53_zone.default.*.name), "/\\.$$/", "")}"
  description = "Route53 DNS Zone name"
}

