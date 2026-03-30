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
  default     = "project-vpc"
}

# ----- EKS змінні -----
variable "cluster_name" {
  description = "Назва EKS кластера"
  type        = string
  default     = "project-eks"
}

variable "cluster_version" {
  description = "Версія Kubernetes"
  type        = string
  default     = "1.29"
}

variable "node_group_name" {
  description = "Назва групи вузлів EKS"
  type        = string
  default     = "project-nodes"
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

variable "node_disk_size" {
  description = "Розмір диску вузла EKS (ГБ)"
  type        = number
  default     = 20
}

# ----- ECR змінні -----
variable "ecr_name" {
  description = "Назва ECR репозиторію"
  type        = string
  default     = "project-ecr"
}

variable "scan_on_push" {
  description = "Увімкнути автоматичне сканування образів при push"
  type        = bool
  default     = true
}

# ----- RDS змінні -----
variable "rds_use_aurora" {
  description = "true — Aurora Cluster, false — звичайна RDS instance"
  type        = bool
  default     = false
}

variable "rds_identifier" {
  description = "Ідентифікатор RDS instance або Aurora кластера"
  type        = string
  default     = "project-db"
}

variable "rds_engine" {
  description = "Движок БД (postgres, mysql, aurora-postgresql, aurora-mysql)"
  type        = string
  default     = "postgres"
}

variable "rds_engine_version" {
  description = "Версія движка БД"
  type        = string
  default     = "15.4"
}

variable "rds_instance_class" {
  description = "Клас інстансу БД"
  type        = string
  default     = "db.t3.medium"
}

variable "rds_db_name" {
  description = "Назва бази даних"
  type        = string
  default     = "appdb"
}

variable "rds_db_username" {
  description = "Логін адміністратора БД"
  type        = string
  default     = "dbadmin"
}

variable "rds_db_password" {
  description = "Пароль адміністратора БД"
  type        = string
  sensitive   = true
}

variable "rds_db_port" {
  description = "Порт підключення до БД"
  type        = number
  default     = 5432
}

variable "rds_multi_az" {
  description = "Увімкнути Multi-AZ для RDS instance"
  type        = bool
  default     = false
}

variable "rds_aurora_replica_count" {
  description = "Кількість reader instances в Aurora кластері"
  type        = number
  default     = 1
}

# ----- Jenkins змінні -----
variable "jenkins_admin_user" {
  description = "Логін адміністратора Jenkins"
  type        = string
  default     = "admin"
}

variable "jenkins_admin_password" {
  description = "Пароль адміністратора Jenkins"
  type        = string
  sensitive   = true
}

# ----- GitHub змінні -----
variable "github_repo_url" {
  description = "HTTPS URL GitHub репозиторію (для Jenkins pipeline та Argo CD Application source)"
  type        = string
}

variable "github_repo_ssh_url" {
  description = "SSH URL GitHub репозиторію для Argo CD (формат: git@github.com:org/repo.git)"
  type        = string
}

variable "github_ssh_key" {
  description = "SSH приватний ключ для доступу до GitHub (для Argo CD)"
  type        = string
  sensitive   = true
}