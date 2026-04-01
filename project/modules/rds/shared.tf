# -----------------------------------------------
# Спільні ресурси для RDS та Aurora
# -----------------------------------------------

locals {
  is_postgres = can(regex("^(postgres|aurora-postgresql)", var.engine))
  is_mysql    = can(regex("^(mysql|aurora-mysql|mariadb)", var.engine))

  # Сімейство parameter group залежить від движка та версії
  parameter_group_family = local.is_postgres ? (
    var.use_aurora
    ? "aurora-postgresql${split(".", var.engine_version)[0]}"
    : "postgres${split(".", var.engine_version)[0]}"
    ) : (
    var.use_aurora
    ? "aurora-mysql${split(".", var.engine_version)[0]}.${split(".", var.engine_version)[1]}"
    : "mysql${split(".", var.engine_version)[0]}.${split(".", var.engine_version)[1]}"
  )
}

# -----------------------------------------------
# DB Subnet Group
# -----------------------------------------------
resource "aws_db_subnet_group" "this" {
  name        = "${var.identifier}-subnet-group"
  description = "Subnet group для ${var.identifier}"
  subnet_ids  = var.subnet_ids

  tags = {
    Name = "${var.identifier}-subnet-group"
  }
}

# -----------------------------------------------
# Security Group
# -----------------------------------------------
resource "aws_security_group" "this" {
  name        = "${var.identifier}-sg"
  description = "Security group для ${var.identifier} RDS"
  vpc_id      = var.vpc_id

  lifecycle {
    precondition {
      condition     = length(var.allowed_cidr_blocks) > 0 || length(var.allowed_security_group_ids) > 0
      error_message = "Необхідно вказати хоча б один allowed_cidr_blocks або allowed_security_group_ids, інакше доступ до БД буде заблокований."
    }
  }

  ingress {
    description     = "DB port від дозволених CIDR"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    cidr_blocks     = var.allowed_cidr_blocks
    security_groups = var.allowed_security_group_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.identifier}-sg"
  }
}

# -----------------------------------------------
# Parameter Group
# -----------------------------------------------
resource "aws_db_parameter_group" "this" {
  count = !var.use_aurora ? 1 : 0

  name        = "${var.identifier}-pg"
  family      = local.parameter_group_family
  description = "Parameter group для ${var.identifier}"

  dynamic "parameter" {
    for_each = local.is_postgres ? [1] : []
    content {
      name  = "max_connections"
      value = var.pg_max_connections
    }
  }

  dynamic "parameter" {
    for_each = local.is_postgres ? [1] : []
    content {
      name  = "log_statement"
      value = var.pg_log_statement
    }
  }

  dynamic "parameter" {
    for_each = local.is_postgres ? [1] : []
    content {
      name  = "work_mem"
      value = var.pg_work_mem
    }
  }

  dynamic "parameter" {
    for_each = local.is_mysql ? [1] : []
    content {
      name         = "max_connections"
      value        = var.pg_max_connections
      apply_method = "pending-reboot"
    }
  }

  tags = {
    Name = "${var.identifier}-pg"
  }
}

resource "aws_rds_cluster_parameter_group" "this" {
  count = var.use_aurora ? 1 : 0

  name        = "${var.identifier}-cluster-pg"
  family      = local.parameter_group_family
  description = "Cluster parameter group для ${var.identifier}"

  dynamic "parameter" {
    for_each = local.is_postgres ? [1] : []
    content {
      name  = "max_connections"
      value = var.pg_max_connections
    }
  }

  dynamic "parameter" {
    for_each = local.is_postgres ? [1] : []
    content {
      name  = "log_statement"
      value = var.pg_log_statement
    }
  }

  dynamic "parameter" {
    for_each = local.is_postgres ? [1] : []
    content {
      name  = "work_mem"
      value = var.pg_work_mem
    }
  }

  dynamic "parameter" {
    for_each = local.is_mysql ? [1] : []
    content {
      name         = "max_connections"
      value        = var.pg_max_connections
      apply_method = "pending-reboot"
    }
  }

  tags = {
    Name = "${var.identifier}-cluster-pg"
  }
}
