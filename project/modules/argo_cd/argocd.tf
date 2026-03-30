# -----------------------------------------------
# Helm release Argo CD в EKS
# -----------------------------------------------

# Namespace для Argo CD
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace

    labels = {
      name = var.namespace
    }
  }
}

# Helm release Argo CD
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  values = [
    templatefile("${path.module}/values.yaml", {
      server_cpu_request    = var.server_cpu_request
      server_memory_request = var.server_memory_request
    })
  ]

  wait          = true
  wait_for_jobs = true
  timeout       = 600

  depends_on = [kubernetes_namespace.argocd]
}

# Helm release для Argo CD Applications (chart у ./charts/)
resource "helm_release" "argocd_apps" {
  name      = "argocd-apps"
  chart     = "${path.module}/charts"
  namespace = kubernetes_namespace.argocd.metadata[0].name

  values = [
    templatefile("${path.module}/charts/values.yaml", {
      github_repo_url     = var.github_repo_url
      github_repo_ssh_url = var.github_repo_ssh_url
      # indent(6, key) вирівнює всі рядки ключа на 6 пробілів —
      # потрібно для коректного YAML block scalar під sshPrivateKey: |
      # YAML парсер зніме відступ при читанні, тому Helm отримає чистий рядок
      github_repo_ssh_key = indent(6, var.github_repo_ssh_key)
      app_name            = var.app_name
      app_namespace       = var.app_namespace
      helm_chart_path     = var.helm_chart_path
      target_revision     = var.target_revision
      argocd_namespace    = var.namespace
    })
  ]

  depends_on = [helm_release.argocd]
}
