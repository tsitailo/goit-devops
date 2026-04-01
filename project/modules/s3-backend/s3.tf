# -----------------------------------------------
# S3-бакет для зберігання стейтів Terraform
# -----------------------------------------------

# Основний S3-бакет
resource "aws_s3_bucket" "terraform_state" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy

  tags = {
    Name        = var.bucket_name
    Description = "Terraform state storage bucket"
  }
}

# Налаштування версіювання для збереження
# всіх версій стейт-файлів
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

# Налаштування шифрування на стороні сервера
# для захисту стейт-файлів
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# Блокування публічного доступу до бакета
# Стейти не повинні бути публічно доступними!
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle policy для управління версіями
resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  # Lifecycle залежить від версіювання
  depends_on = [aws_s3_bucket_versioning.terraform_state]

  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id     = "state-lifecycle"
    status = "Enabled"

    filter {}

    # Зберігаємо старі версії 90 днів
    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    # Переміщуємо старі версії в дешевший клас зберігання
    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }
  }
}