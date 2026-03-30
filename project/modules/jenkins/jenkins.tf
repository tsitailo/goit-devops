# -----------------------------------------------
# Helm release Jenkins в EKS
# -----------------------------------------------

# Namespace для Jenkins
resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = var.namespace

    labels = {
      name = var.namespace
    }
  }
}

# Helm release Jenkins
resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = var.chart_version
  namespace  = kubernetes_namespace.jenkins.metadata[0].name

  # Рендеримо values.yaml із підстановкою змінних
  values = [
    templatefile("${path.module}/values.yaml", {
      admin_user                = var.admin_user
      admin_password            = var.admin_password
      controller_cpu_request    = var.controller_cpu_request
      controller_memory_request = var.controller_memory_request
      controller_cpu_limit      = var.controller_cpu_limit
      controller_memory_limit   = var.controller_memory_limit
      storage_size              = var.storage_size
      aws_account_id            = var.aws_account_id
      aws_region                = var.aws_region
      ecr_name                  = var.ecr_name
      github_repo_url           = var.github_repo_url
      namespace                 = var.namespace
      irsa_role_arn             = aws_iam_role.jenkins.arn
    })
  ]

  # Очікуємо повного розгортання
  wait          = true
  wait_for_jobs = true
  timeout       = 600

  depends_on = [
    kubernetes_namespace.jenkins,
    aws_iam_role_policy_attachment.jenkins_ecr,
  ]
}
