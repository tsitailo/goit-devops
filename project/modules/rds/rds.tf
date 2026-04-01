# -----------------------------------------------
# Звичайна RDS Instance (use_aurora = false)
# -----------------------------------------------

resource "aws_db_instance" "this" {
  count = !var.use_aurora ? 1 : 0

  identifier = var.identifier

  # Движок
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  # Сховище
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage > 0 ? var.max_allocated_storage : null
  storage_type          = var.storage_type
  storage_encrypted     = var.storage_encrypted

  # Креденшели
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = var.db_port

  # Мережа
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]
  publicly_accessible    = false
  multi_az               = var.multi_az

  # Parameter Group
  parameter_group_name = aws_db_parameter_group.this[0].name

  # Резервні копії
  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  # Безпека
  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.identifier}-final-snapshot"

  # Моніторинг
  performance_insights_enabled = var.performance_insights_enabled
  monitoring_interval          = var.monitoring_interval

  tags = {
    Name = var.identifier
  }
}
