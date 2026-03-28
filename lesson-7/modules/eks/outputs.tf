# -----------------------------------------------
# Виводи модуля EKS
# -----------------------------------------------

output "cluster_name" {
  description = "Назва EKS кластера"
  value       = aws_eks_cluster.main.name
}

output "cluster_arn" {
  description = "ARN EKS кластера"
  value       = aws_eks_cluster.main.arn
}

output "cluster_endpoint" {
  description = "Endpoint API сервера EKS кластера"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_version" {
  description = "Версія Kubernetes кластера"
  value       = aws_eks_cluster.main.version
}

output "cluster_certificate_authority" {
  description = "Certificate Authority для підключення до кластера"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

output "cluster_security_group_id" {
  description = "ID Security Group кластера"
  value       = aws_security_group.eks_cluster.id
}

output "node_group_arn" {
  description = "ARN групи вузлів"
  value       = aws_eks_node_group.main.arn
}

output "node_role_arn" {
  description = "ARN IAM ролі вузлів"
  value       = aws_iam_role.eks_nodes.arn
}

output "kubeconfig_command" {
  description = "Команда для налаштування kubectl"
  value       = "aws eks update-kubeconfig --name ${aws_eks_cluster.main.name}"
}
