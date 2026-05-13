output "cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "ecr_repository_url" {
  value = aws_ecr_repository.api.repository_url
}

output "service_name" {
  value = aws_ecs_service.api.name
}