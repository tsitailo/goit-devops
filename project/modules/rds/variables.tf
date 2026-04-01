# -----------------------------------------------
# Змінні для модуля RDS
# -----------------------------------------------

# ----- Режим розгортання -----
variable "use_aurora" {
  description = "true — створити Aurora Cluster, false — створити звичайну RDS instance"
  type        = bool
  default     = false
}

# ----- Ідентифікація -----
variable "identifier" {
  description = "Унікальний ідентифікатор для RDS instance або Aurora кластера"
  type        = string
}

# ----- Мережа -----
variable "vpc_id" {
  description = "ID VPC, в якому розгортається БД"
  type        = string
}

variable "subnet_ids" {
  description = "Список ID приватних підмереж для DB Subnet Group"
  type        = list(string)
}

variable "allowed_cidr_blocks" {
  description = "CIDR блоки, яким дозволено підключатися до БД. Якщо обидва списки (allowed_cidr_blocks та allowed_security_group_ids) порожні — ingress правило створюється без джерел і доступу до БД не буде."
  type        = list(string)
  default     = []
}

variable "allowed_security_group_ids" {
  description = "ID security groups, яким дозволено підключатися до БД"
  type        = list(string)
  default     = []
}

# ----- Движок БД -----
variable "engine" {
  description = "Движок БД (наприклад: postgres, mysql, aurora-postgresql, aurora-mysql)"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Версія движка БД. Формат: major.minor для PostgreSQL (наприклад: \"15.4\"), major.minor.patch для MySQL (наприклад: \"8.0.35\"). Aurora використовує той самий формат що й відповідний движок."
  type        = string
  default     = "15.4"
}

variable "instance_class" {
  description = "Клас інстансу БД (наприклад: db.t3.medium)"
  type        = string
  default     = "db.t3.medium"
}

# ----- Параметри сховища (лише для RDS instance) -----
variable "allocated_storage" {
  description = "Початковий розмір сховища в ГБ (лише для RDS instance)"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Максимальний розмір сховища для autoscaling в ГБ (0 = вимкнено, лише для RDS instance)"
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "Тип сховища: gp2, gp3, io1 (лише для RDS instance)"
  type        = string
  default     = "gp3"
}

# ----- Креденшели -----
variable "db_name" {
  description = "Назва бази даних"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Логін адміністратора БД"
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "Пароль адміністратора БД"
  type        = string
  sensitive   = true
}

# ----- Порт -----
variable "db_port" {
  description = "Порт підключення до БД (5432 для PostgreSQL, 3306 для MySQL)"
  type        = number
  default     = 5432
}

# ----- Доступність та резервування -----
variable "multi_az" {
  description = "Увімкнути Multi-AZ для RDS instance (для Aurora визначається кількістю replica_count)"
  type        = bool
  default     = false
}

variable "aurora_replica_count" {
  description = "Кількість reader instances в Aurora кластері (лише для use_aurora = true)"
  type        = number
  default     = 1
}

# ----- Резервні копії -----
variable "backup_retention_period" {
  description = "Кількість днів зберігання автоматичних резервних копій"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Вікно для автоматичного резервного копіювання (UTC)"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Вікно для технічного обслуговування"
  type        = string
  default     = "Mon:04:00-Mon:05:00"
}

# ----- Безпека -----
variable "deletion_protection" {
  description = "Увімкнути захист від видалення"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Пропустити фінальний snapshot при видаленні"
  type        = bool
  default     = true
}

variable "storage_encrypted" {
  description = "Увімкнути шифрування сховища"
  type        = bool
  default     = true
}

# ----- Моніторинг -----
variable "performance_insights_enabled" {
  description = "Увімкнути Performance Insights"
  type        = bool
  default     = false
}

variable "monitoring_interval" {
  description = "Інтервал Enhanced Monitoring в секундах (0 = вимкнено)"
  type        = number
  default     = 0
}

# ----- Parameter Group -----
variable "pg_max_connections" {
  description = "Значення параметра max_connections"
  type        = string
  default     = "200"
}

variable "pg_log_statement" {
  description = "Значення параметра log_statement (none, ddl, mod, all)"
  type        = string
  default     = "ddl"
}

variable "pg_work_mem" {
  description = "Значення параметра work_mem (в кілобайтах, лише для PostgreSQL)"
  type        = string
  default     = "65536"
}
