# -----------------------------------------------
# Змінні для модуля S3 Backend
# -----------------------------------------------

variable "bucket_name" {
  description = "Унікальна назва S3-бакета для стейтів Terraform"
  type        = string

  validation {
    condition     = length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63
    error_message = "Назва бакета повинна містити від 3 до 63 символів."
  }
}

variable "table_name" {
  description = "Назва таблиці DynamoDB для блокування стейтів"
  type        = string
  default     = "terraform-locks"
}

variable "aws_region" {
  description = "AWS регіон"
  type        = string
  default     = "us-west-2"
}

variable "enable_versioning" {
  description = "Увімкнути версіювання для S3-бакета"
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Дозволити видалення бакета з вмістом"
  type        = bool
  default     = false
}