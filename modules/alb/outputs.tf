output "alb_dns_name" {
  value = aws_lb.example.dns_name
}

output "alb_zone_id" {
  value = aws_lb.example.zone_id
}

output "target_group_arn" {
  value = aws_lb_target_group.example.arn
}