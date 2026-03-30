# -----------------------------------------------
# Вихідні дані модуля RDS
# -----------------------------------------------

# ----- Endpoint для підключення -----
output "endpoint" {
  description = "Endpoint для підключення до БД (writer endpoint для Aurora, instance endpoint для RDS)"
  value       = var.use_aurora ? aws_rds_cluster.this[0].endpoint : aws_db_instance.this[0].address
}

output "reader_endpoint" {
  description = "Reader endpoint (лише для Aurora)"
  value       = var.use_aurora ? aws_rds_cluster.this[0].reader_endpoint : null
}

output "port" {
  description = "Порт БД"
  value       = var.use_aurora ? aws_rds_cluster.this[0].port : aws_db_instance.this[0].port
}

# ----- Ідентифікатори -----
output "cluster_id" {
  description = "ID Aurora кластера (лише для Aurora)"
  value       = var.use_aurora ? aws_rds_cluster.this[0].cluster_identifier : null
}

output "instance_id" {
  description = "ID RDS instance (лише для звичайної RDS)"
  value       = !var.use_aurora ? aws_db_instance.this[0].identifier : null
}

# ----- Мережа -----
output "security_group_id" {
  description = "ID Security Group модуля RDS"
  value       = aws_security_group.this.id
}

output "subnet_group_name" {
  description = "Назва DB Subnet Group"
  value       = aws_db_subnet_group.this.name
}

# ----- Підключення -----
output "db_name" {
  description = "Назва бази даних"
  value       = var.db_name
}

output "db_username" {
  description = "Логін адміністратора БД"
  value       = var.db_username
}

# ----- Secrets Manager -----
output "secret_arn" {
  description = "ARN секрету в AWS Secrets Manager з паролем БД"
  value       = aws_secretsmanager_secret.db_password.arn
}

output "secret_name" {
  description = "Назва секрету в AWS Secrets Manager"
  value       = aws_secretsmanager_secret.db_password.name
}

output "connection_string" {
  description = "Рядок підключення (без пароля)"
  sensitive   = false
  value = local.is_postgres ? (
    var.use_aurora
    ? "postgresql://${var.db_username}@${aws_rds_cluster.this[0].endpoint}:${aws_rds_cluster.this[0].port}/${var.db_name}"
    : "postgresql://${var.db_username}@${aws_db_instance.this[0].address}:${aws_db_instance.this[0].port}/${var.db_name}"
    ) : (
    var.use_aurora
    ? "mysql://${var.db_username}@${aws_rds_cluster.this[0].endpoint}:${aws_rds_cluster.this[0].port}/${var.db_name}"
    : "mysql://${var.db_username}@${aws_db_instance.this[0].address}:${aws_db_instance.this[0].port}/${var.db_name}"
  )
}
