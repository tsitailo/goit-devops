# -----------------------------------------------
# Змінні для модуля Monitoring (Prometheus + Grafana)
# -----------------------------------------------

variable "namespace" {
  description = "Kubernetes namespace для Prometheus та Grafana"
  type        = string
  default     = "monitoring"
}

variable "prometheus_chart_version" {
  description = "Версія Helm chart prometheus-community/prometheus"
  type        = string
  default     = "25.21.0"
}

variable "grafana_chart_version" {
  description = "Версія Helm chart grafana/grafana"
  type        = string
  default     = "7.3.11"
}

variable "grafana_admin_password" {
  description = "Пароль адміністратора Grafana"
  type        = string
  sensitive   = true
  default     = "admin123"
}

variable "prometheus_retention" {
  description = "Час зберігання метрик Prometheus"
  type        = string
  default     = "15d"
}

variable "prometheus_storage_size" {
  description = "Розмір PersistentVolume для Prometheus"
  type        = string
  default     = "10Gi"
}

variable "grafana_storage_size" {
  description = "Розмір PersistentVolume для Grafana"
  type        = string
  default     = "5Gi"
}
