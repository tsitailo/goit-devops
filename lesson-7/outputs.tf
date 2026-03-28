# -----------------------------------------------
# Загальні вихідні дані з усіх модулів
# -----------------------------------------------

# ----- S3 Backend виводи -----
output "s3_bucket_name" {
  description = "Назва S3-бакета для зберігання стейтів"
  value       = module.s3_backend.bucket_name
}

output "s3_bucket_arn" {
  description = "ARN S3-бакета"
  value       = module.s3_backend.bucket_arn
}

output "dynamodb_table_name" {
  description = "Назва таблиці DynamoDB для блокування стейтів"
  value       = module.s3_backend.dynamodb_table_name
}

output "dynamodb_table_arn" {
  description = "ARN таблиці DynamoDB"
  value       = module.s3_backend.dynamodb_table_arn
}

# ----- VPC виводи -----
output "vpc_id" {
  description = "ID створеного VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR блок VPC"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "Список ID публічних підмереж"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Список ID приватних підмереж"
  value       = module.vpc.private_subnet_ids
}

output "internet_gateway_id" {
  description = "ID Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

output "nat_gateway_ids" {
  description = "Список ID NAT Gateway"
  value       = module.vpc.nat_gateway_ids
}

# ----- ECR виводи -----
output "ecr_repository_url" {
  description = "URL ECR репозиторію"
  value       = module.ecr.repository_url
}

output "ecr_repository_arn" {
  description = "ARN ECR репозиторію"
  value       = module.ecr.repository_arn
}

output "ecr_registry_id" {
  description = "ID реєстру ECR"
  value       = module.ecr.registry_id
}

# ----- EKS виводи -----
output "eks_cluster_name" {
  description = "Назва EKS кластера"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint API сервера EKS кластера"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_version" {
  description = "Версія Kubernetes кластера"
  value       = module.eks.cluster_version
}

output "eks_kubeconfig_command" {
  description = "Команда для налаштування kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}