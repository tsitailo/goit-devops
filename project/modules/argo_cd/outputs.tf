# -----------------------------------------------
# Виводи модуля Argo CD
# -----------------------------------------------

output "argocd_namespace" {
  description = "Kubernetes namespace де розгорнуто Argo CD"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "argocd_service_name" {
  description = "Назва Kubernetes Service для Argo CD server"
  value       = "argocd-server"
}

output "argocd_url_command" {
  description = "Команда для отримання зовнішнього URL Argo CD"
  value       = "kubectl get svc -n ${kubernetes_namespace.argocd.metadata[0].name} argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
}

output "argocd_initial_password_command" {
  description = "Команда для отримання початкового пароля адміна Argo CD"
  value       = "kubectl get secret -n ${kubernetes_namespace.argocd.metadata[0].name} argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}
