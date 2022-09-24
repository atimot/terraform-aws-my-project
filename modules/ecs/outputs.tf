output "cluster_name" {
  value = aws_ecs_cluster.example.name
  description = "ECS cluster name."
}

output "service_name" {
  value = aws_ecs_service.example.name
  description = "ECS service name."
}