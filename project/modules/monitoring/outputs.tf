# -----------------------------------------------
# Вихідні дані модуля Monitoring
# -----------------------------------------------

output "monitoring_namespace" {
  description = "Kubernetes namespace для Prometheus та Grafana"
  value       = kubernetes_namespace.monitoring.metadata[0].name
}

output "prometheus_url_command" {
  description = "Команда для отримання URL Prometheus (port-forward)"
  value       = "kubectl port-forward svc/prometheus-server 9090:80 -n ${var.namespace}"
}

output "grafana_url_command" {
  description = "Команда для отримання URL Grafana (port-forward)"
  value       = "kubectl port-forward svc/grafana 3000:80 -n ${var.namespace}"
}

output "grafana_password_command" {
  description = "Команда для отримання пароля адміна Grafana із K8s Secret"
  value       = "kubectl get secret --namespace ${var.namespace} grafana -o jsonpath='{.data.admin-password}' | base64 --decode"
}
