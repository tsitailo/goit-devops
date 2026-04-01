# -----------------------------------------------
# Helm releases Prometheus та Grafana в EKS
# -----------------------------------------------

# Namespace для моніторингу
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.namespace

    labels = {
      name = var.namespace
    }
  }
}

# Helm release Prometheus
resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  version    = var.prometheus_chart_version
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  values = [
    templatefile("${path.module}/prometheus-values.yaml", {
      prometheus_retention    = var.prometheus_retention
      prometheus_storage_size = var.prometheus_storage_size
    })
  ]

  wait    = true
  timeout = 600

  depends_on = [kubernetes_namespace.monitoring]
}

# Helm release Grafana
resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = var.grafana_chart_version
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  values = [
    templatefile("${path.module}/grafana-values.yaml", {
      grafana_admin_password = var.grafana_admin_password
      grafana_storage_size   = var.grafana_storage_size
      namespace              = var.namespace
    })
  ]

  wait    = true
  timeout = 600

  depends_on = [
    kubernetes_namespace.monitoring,
    helm_release.prometheus,
  ]
}
