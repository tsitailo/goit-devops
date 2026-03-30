# -----------------------------------------------
# Змінні для модуля Jenkins
# -----------------------------------------------

variable "cluster_name" {
  description = "Назва EKS кластера для розгортання Jenkins"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace для Jenkins"
  type        = string
  default     = "jenkins"
}

variable "chart_version" {
  description = "Версія Helm chart jenkinsci/jenkins"
  type        = string
  default     = "5.1.30"
}

variable "admin_user" {
  description = "Логін адміністратора Jenkins"
  type        = string
  default     = "admin"
}

variable "admin_password" {
  description = "Пароль адміністратора Jenkins"
  type        = string
  sensitive   = true
}

variable "aws_region" {
  description = "AWS регіон (використовується для ECR URL)"
  type        = string
  default     = "us-west-2"
}

variable "aws_account_id" {
  description = "AWS Account ID (використовується для ECR URL в Kaniko)"
  type        = string
}

variable "github_repo_url" {
  description = "URL GitHub репозиторію (для pipeline та git push)"
  type        = string
}

variable "controller_cpu_request" {
  description = "CPU request для контролера Jenkins"
  type        = string
  default     = "500m"
}

variable "controller_memory_request" {
  description = "Memory request для контролера Jenkins"
  type        = string
  default     = "512Mi"
}

variable "controller_cpu_limit" {
  description = "CPU limit для контролера Jenkins"
  type        = string
  default     = "1000m"
}

variable "controller_memory_limit" {
  description = "Memory limit для контролера Jenkins"
  type        = string
  default     = "1Gi"
}

variable "storage_size" {
  description = "Розмір PersistentVolume для Jenkins home"
  type        = string
  default     = "20Gi"
}

variable "oidc_provider_arn" {
  description = "ARN OIDC провайдера EKS (для IRSA)"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL OIDC провайдера EKS без https:// (для IRSA)"
  type        = string
}

variable "ecr_name" {
  description = "Назва ECR репозиторію (використовується в Kaniko для push образів)"
  type        = string
}
