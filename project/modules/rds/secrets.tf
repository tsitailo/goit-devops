# -----------------------------------------------
# AWS Secrets Manager — зберігання пароля БД
# -----------------------------------------------

resource "aws_secretsmanager_secret" "db_password" {
  name                    = "${var.identifier}/db-password"
  description             = "Пароль адміністратора БД ${var.identifier}"
  recovery_window_in_days = 0 # 0 = негайне видалення (dev); мінімум з вікном відновлення = 7

  tags = {
    Name = "${var.identifier}-db-password"
  }
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    password = var.db_password
    username = var.db_username
    dbname   = var.db_name
    host     = var.use_aurora ? aws_rds_cluster.this[0].endpoint : aws_db_instance.this[0].address
    port     = tostring(var.db_port)
  })

}
