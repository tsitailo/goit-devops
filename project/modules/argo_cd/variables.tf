# -----------------------------------------------
# Змінні для модуля Argo CD
# -----------------------------------------------

variable "namespace" {
  description = "Kubernetes namespace для Argo CD"
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "Версія Helm chart argo/argo-cd"
  type        = string
  default     = "7.6.12"
}

variable "github_repo_url" {
  description = "HTTPS URL GitHub репозиторію (Argo CD стежить за ним)"
  type        = string
}

variable "github_repo_ssh_url" {
  description = "SSH URL GitHub репозиторію для Argo CD (формат: git@github.com:org/repo.git)"
  type        = string
}

variable "github_repo_ssh_key" {
  description = "SSH приватний ключ для доступу до GitHub репозиторію"
  type        = string
  sensitive   = true
}

variable "app_name" {
  description = "Назва Argo CD Application"
  type        = string
  default     = "django-app"
}

variable "app_namespace" {
  description = "Kubernetes namespace для розгортання Django-застосунку"
  type        = string
  default     = "default"
}

variable "helm_chart_path" {
  description = "Шлях до Helm chart в репозиторії"
  type        = string
  default     = "charts/django-app"
}

variable "target_revision" {
  description = "Git гілка або тег для відстеження"
  type        = string
  default     = "main"
}

variable "server_cpu_request" {
  description = "CPU request для Argo CD server"
  type        = string
  default     = "250m"
}

variable "server_memory_request" {
  description = "Memory request для Argo CD server"
  type        = string
  default     = "256Mi"
}
