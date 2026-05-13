output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnet_ids
}

output "private_subnets" {
  value = module.vpc.private_subnet_ids
}

output "dynamodb_table" {
  value = module.dynamodb.table_name
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "ecr_repository_url" {
  value = module.ecs.ecr_repository_url
}

output "cluster_name" {
  value = module.ecs.cluster_name
}