# -----------------------------------------------
# Виводи модуля Jenkins
# -----------------------------------------------

output "jenkins_namespace" {
  description = "Kubernetes namespace де розгорнуто Jenkins"
  value       = kubernetes_namespace.jenkins.metadata[0].name
}

output "jenkins_service_name" {
  description = "Назва Kubernetes Service для Jenkins"
  value       = "${helm_release.jenkins.name}-controller"
}

output "jenkins_admin_secret" {
  description = "Назва Kubernetes Secret з паролем адміна"
  value       = helm_release.jenkins.name
}

output "jenkins_url_command" {
  description = "Команда для отримання зовнішнього URL Jenkins"
  value       = "kubectl get svc -n ${kubernetes_namespace.jenkins.metadata[0].name} ${helm_release.jenkins.name}-controller -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
}
