# -----------------------------------------------
# IRSA — IAM Role for Service Account для Jenkins
# Дає Jenkins ServiceAccount права на push у ECR
# -----------------------------------------------

# Assume role policy: дозволяємо Jenkins ServiceAccount використовувати роль
data "aws_iam_policy_document" "jenkins_assume_role" {
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
      values   = ["system:serviceaccount:${var.namespace}:jenkins"]
    }
  }
}

resource "aws_iam_role" "jenkins" {
  name               = "${var.cluster_name}-jenkins-irsa"
  assume_role_policy = data.aws_iam_policy_document.jenkins_assume_role.json

  tags = {
    Name = "${var.cluster_name}-jenkins-irsa"
  }
}

# Дозволяємо push та pull в ECR
data "aws_iam_policy_document" "jenkins_ecr" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
    ]
    resources = ["arn:aws:ecr:${var.aws_region}:${var.aws_account_id}:repository/*"]
  }
}

resource "aws_iam_policy" "jenkins_ecr" {
  name        = "${var.cluster_name}-jenkins-ecr-policy"
  description = "Права Jenkins на push/pull образів у ECR"
  policy      = data.aws_iam_policy_document.jenkins_ecr.json
}

resource "aws_iam_role_policy_attachment" "jenkins_ecr" {
  policy_arn = aws_iam_policy.jenkins_ecr.arn
  role       = aws_iam_role.jenkins.name
}
