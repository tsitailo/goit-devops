# -----------------------------------------------
# ECR репозиторій для Docker образів
# -----------------------------------------------

# Отримуємо інформацію про поточний AWS акаунт та регіон
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Основний ECR репозиторій
resource "aws_ecr_repository" "main" {
  name                 = var.ecr_name
  image_tag_mutability = var.image_tag_mutability
  force_delete         = var.force_delete

  # Налаштування автоматичного сканування образів
  # на наявність вразливостей при кожному push
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  # Шифрування образів у репозиторії
  encryption_configuration {
    encryption_type = var.encryption_type
  }

  tags = {
    Name = var.ecr_name
  }
}

# -----------------------------------------------
# Lifecycle Policy - автоматичне видалення
# старих образів для економії місця
# -----------------------------------------------
resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    rules = [
      {
        # Правило 1: Зберігаємо лише N останніх tagged образів
        # Охоплює будь-який формат тегу (включаючи BUILD_NUMBER-SHA7 від Jenkins)
        rulePriority = 1
        description  = "Зберігати тільки останні ${var.max_image_count} tagged образів"
        selection = {
          tagStatus   = "tagged"
          tagPatternList = ["*"]
          countType   = "imageCountMoreThan"
          countNumber = var.max_image_count
        }
        action = {
          type = "expire"
        }
      },
      {
        # Правило 2: Видаляємо untagged образи старші 14 днів
        rulePriority = 2
        description  = "Видаляти untagged образи старші 14 днів"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 14
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# -----------------------------------------------
# Repository Policy - налаштування доступу
# до ECR репозиторію
# -----------------------------------------------
resource "aws_ecr_repository_policy" "main" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Дозволяємо поточному акаунту повний доступ
        Sid    = "AllowCurrentAccountAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories",
          "ecr:GetRepositoryPolicy",
          "ecr:ListImages",
          "ecr:DeleteRepository",
          "ecr:BatchDeleteImage",
          "ecr:SetRepositoryPolicy",
          "ecr:DeleteRepositoryPolicy"
        ]
      }
    ]
  })
}