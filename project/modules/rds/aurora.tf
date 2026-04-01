# -----------------------------------------------
# Aurora Cluster + Writer Instance (use_aurora = true)
# -----------------------------------------------

resource "aws_rds_cluster" "this" {
  count = var.use_aurora ? 1 : 0

  cluster_identifier = var.identifier

  # Движок
  engine         = var.engine
  engine_version = var.engine_version

  # Креденшели
  database_name   = var.db_name
  master_username = var.db_username
  master_password = var.db_password
  port            = var.db_port

  # Мережа
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]

  # Parameter Group
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this[0].name

  # Резервні копії
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.backup_window

  # Безпека
  storage_encrypted         = var.storage_encrypted
  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.identifier}-final-snapshot"

  tags = {
    Name = var.identifier
  }
}

# Writer instance
resource "aws_rds_cluster_instance" "writer" {
  count = var.use_aurora ? 1 : 0

  identifier         = "${var.identifier}-writer"
  cluster_identifier = aws_rds_cluster.this[0].id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.this[0].engine
  engine_version     = aws_rds_cluster.this[0].engine_version

  db_subnet_group_name = aws_db_subnet_group.this.name

  performance_insights_enabled = var.performance_insights_enabled
  monitoring_interval          = var.monitoring_interval

  tags = {
    Name = "${var.identifier}-writer"
    Role = "writer"
  }
}

# Reader instances
resource "aws_rds_cluster_instance" "reader" {
  count = var.use_aurora ? var.aurora_replica_count : 0

  identifier         = "${var.identifier}-reader-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.this[0].id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.this[0].engine
  engine_version     = aws_rds_cluster.this[0].engine_version

  db_subnet_group_name = aws_db_subnet_group.this.name

  performance_insights_enabled = var.performance_insights_enabled
  monitoring_interval          = var.monitoring_interval

  tags = {
    Name = "${var.identifier}-reader-${count.index + 1}"
    Role = "reader"
  }
}
