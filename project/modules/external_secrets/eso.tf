# -----------------------------------------------
# External Secrets Operator
# Встановлюється через Helm у EKS кластер
# -----------------------------------------------

resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  version          = var.eso_chart_version
  namespace        = "external-secrets"
  create_namespace = true

  wait          = true
  wait_for_jobs = true
  timeout       = 300
}

# -----------------------------------------------
# IRSA — IAM Role for Service Account ESO
# Дає ESO права читати секрети з Secrets Manager
# -----------------------------------------------

data "aws_iam_policy_document" "eso_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_url}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_url}:sub"
      values   = ["system:serviceaccount:external-secrets:external-secrets"]
    }
  }
}

resource "aws_iam_role" "eso" {
  name               = "${var.cluster_name}-eso-irsa"
  assume_role_policy = data.aws_iam_policy_document.eso_assume_role.json

  tags = {
    Name = "${var.cluster_name}-eso-irsa"
  }
}

data "aws_iam_policy_document" "eso_secrets" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]
    resources = var.secret_arns
  }
}

resource "aws_iam_policy" "eso_secrets" {
  name        = "${var.cluster_name}-eso-secrets-policy"
  description = "Права ESO на читання секретів з Secrets Manager"
  policy      = data.aws_iam_policy_document.eso_secrets.json
}

resource "aws_iam_role_policy_attachment" "eso_secrets" {
  policy_arn = aws_iam_policy.eso_secrets.arn
  role       = aws_iam_role.eso.name
}

# -----------------------------------------------
# Анотація IRSA на ServiceAccount ESO
# -----------------------------------------------

resource "kubernetes_annotations" "eso_sa" {
  api_version = "v1"
  kind        = "ServiceAccount"
  force       = true # Потрібно для патчу SA, створеного Helm

  metadata {
    name      = "external-secrets"
    namespace = "external-secrets"
  }

  annotations = {
    "eks.amazonaws.com/role-arn" = aws_iam_role.eso.arn
  }

  depends_on = [helm_release.external_secrets]
}
