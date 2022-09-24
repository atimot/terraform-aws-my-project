output "domain_name" {
  value = data.aws_route53_zone.example.name
  description = "Route53 domain name."
}

output "zone_id" {
  value = data.aws_route53_zone.example.zone_id
  description = "Route53 zone id."
}
