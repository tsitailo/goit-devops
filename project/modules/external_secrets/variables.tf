# -----------------------------------------------
# Змінні модуля External Secrets Operator
# -----------------------------------------------

variable "cluster_name" {
  description = "Назва EKS кластера"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN OIDC провайдера EKS (для IRSA)"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL OIDC провайдера EKS без https:// (для IRSA)"
  type        = string
}

variable "secret_arns" {
  description = "Список ARN секретів з AWS Secrets Manager, до яких ESO матиме доступ"
  type        = list(string)
}

variable "eso_chart_version" {
  description = "Версія Helm chart external-secrets/external-secrets"
  type        = string
  default     = "0.10.4"
}
