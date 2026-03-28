# -----------------------------------------------
# Виводи модуля ECR
# -----------------------------------------------

output "repository_url" {
  description = "URL ECR репозиторію для push/pull образів"
  value       = aws_ecr_repository.main.repository_url
}

output "repository_arn" {
  description = "ARN ECR репозиторію"
  value       = aws_ecr_repository.main.arn
}

output "registry_id" {
  description = "ID реєстру ECR (номер AWS акаунту)"
  value       = aws_ecr_repository.main.registry_id
}

output "repository_name" {
  description = "Назва ECR репозиторію"
  value       = aws_ecr_repository.main.name
}

output "docker_push_commands" {
  description = "Команди для push Docker образу"
  value = {
    login  = "aws ecr get-login-password --region ${data.aws_region.current.name} | docker login --username AWS --password-stdin ${aws_ecr_repository.main.registry_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
    tag    = "docker tag my-image:latest ${aws_ecr_repository.main.repository_url}:latest"
    push   = "docker push ${aws_ecr_repository.main.repository_url}:latest"
  }
}