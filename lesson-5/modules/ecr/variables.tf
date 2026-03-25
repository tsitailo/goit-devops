# -----------------------------------------------
# Змінні для модуля ECR
# -----------------------------------------------

variable "ecr_name" {
  description = "Назва ECR репозиторію"
  type        = string

  validation {
    condition = can(regex("^[a-z0-9][a-z0-9/_.-]{1,253}[a-z0-9]$", var.ecr_name))
    error_message = "Назва ECR репозиторію повинна містити лише малі літери, цифри та символи /, _, ., -."
  }
}

variable "scan_on_push" {
  description = "Автоматично сканувати образи при push"
  type        = bool
  default     = true
}

variable "image_tag_mutability" {
  description = "Мутабельність тегів образів (MUTABLE або IMMUTABLE)"
  type        = string
  default     = "MUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "Значення має бути MUTABLE або IMMUTABLE."
  }
}

variable "force_delete" {
  description = "Видалити репозиторій навіть якщо він містить образи"
  type        = bool
  default     = false
}

variable "max_image_count" {
  description = "Максимальна кількість образів у репозиторії"
  type        = number
  default     = 10
}

variable "encryption_type" {
  description = "Тип шифрування (AES256 або KMS)"
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "Тип шифрування має бути AES256 або KMS."
  }
}