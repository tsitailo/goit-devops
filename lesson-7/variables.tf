# -----------------------------------------------
# Змінні кореневого модуля
# -----------------------------------------------

variable "aws_region" {
  description = "AWS регіон для розгортання ресурсів"
  type        = string
  default     = "us-west-2"
}

# ----- S3 та DynamoDB змінні -----
variable "bucket_name" {
  description = "Унікальна назва S3-бакета для стейтів Terraform"
  type        = string
  default     = "your-unique-bucket-name" # Змініть на унікальне ім'я
}

variable "table_name" {
  description = "Назва таблиці DynamoDB для блокування стейтів"
  type        = string
  default     = "terraform-locks"
}

# ----- VPC змінні -----
variable "vpc_cidr_block" {
  description = "CIDR блок для VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "Список CIDR блоків для публічних підмереж"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets" {
  description = "Список CIDR блоків для приватних підмереж"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "availability_zones" {
  description = "Список зон доступності"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "vpc_name" {
  description = "Назва VPC"
  type        = string
  default     = "lesson-7-vpc"
}

# ----- EKS змінні -----
variable "cluster_name" {
  description = "Назва EKS кластера"
  type        = string
  default     = "lesson-7-eks"
}

variable "cluster_version" {
  description = "Версія Kubernetes"
  type        = string
  default     = "1.29"
}

variable "node_group_name" {
  description = "Назва групи вузлів EKS"
  type        = string
  default     = "lesson-7-nodes"
}

variable "node_instance_types" {
  description = "Типи EC2 інстансів для вузлів EKS"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Бажана кількість вузлів"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Мінімальна кількість вузлів"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Максимальна кількість вузлів"
  type        = number
  default     = 4
}

# ----- ECR змінні -----
variable "ecr_name" {
  description = "Назва ECR репозиторію"
  type        = string
  default     = "lesson-7-ecr"
}

variable "scan_on_push" {
  description = "Увімкнути автоматичне сканування образів при push"
  type        = bool
  default     = true
}