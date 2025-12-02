# Database Module - Multi-Cloud PostgreSQL

terraform {
  required_version = ">= 1.6.0"
}

# AWS RDS PostgreSQL
resource "aws_db_subnet_group" "main" {
  count = var.cloud_provider == "aws" ? 1 : 0

  name       = "${var.project_name}-${var.environment}-db-subnet"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-db-subnet"
  })
}

resource "aws_security_group" "db" {
  count = var.cloud_provider == "aws" ? 1 : 0

  name        = "${var.project_name}-${var.environment}-db-sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.allowed_security_groups
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-db-sg"
  })
}

resource "aws_db_instance" "main" {
  count = var.cloud_provider == "aws" ? 1 : 0

  identifier = "${var.project_name}-${var.environment}-db"

  engine               = "postgres"
  engine_version       = var.postgres_version
  instance_class       = var.instance_class
  allocated_storage    = var.storage_size
  max_allocated_storage = var.max_storage_size
  storage_type         = "gp3"
  storage_encrypted    = true

  db_name  = var.database_name
  username = var.master_username
  password = var.master_password

  db_subnet_group_name   = aws_db_subnet_group.main[0].name
  vpc_security_group_ids = [aws_security_group.db[0].id]

  multi_az               = var.multi_az
  publicly_accessible    = false
  skip_final_snapshot    = var.environment != "prod"
  deletion_protection    = var.environment == "prod"

  backup_retention_period = var.backup_retention_days
  backup_window          = "03:00-04:00"
  maintenance_window     = "Mon:04:00-Mon:05:00"

  performance_insights_enabled = true
  monitoring_interval          = 60
  monitoring_role_arn          = var.monitoring_role_arn

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-db"
  })
}

# GCP Cloud SQL PostgreSQL
resource "google_sql_database_instance" "main" {
  count = var.cloud_provider == "gcp" ? 1 : 0

  name             = "${var.project_name}-${var.environment}-db"
  database_version = "POSTGRES_${replace(var.postgres_version, ".", "_")}"
  region           = var.region

  deletion_protection = var.environment == "prod"

  settings {
    tier              = var.instance_class
    availability_type = var.multi_az ? "REGIONAL" : "ZONAL"
    disk_size         = var.storage_size
    disk_type         = "PD_SSD"
    disk_autoresize   = true

    backup_configuration {
      enabled                        = true
      start_time                     = "03:00"
      point_in_time_recovery_enabled = true
      backup_retention_settings {
        retained_backups = var.backup_retention_days
      }
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_id
      require_ssl     = true
    }

    insights_config {
      query_insights_enabled  = true
      query_string_length     = 1024
      record_application_tags = true
      record_client_address   = true
    }

    maintenance_window {
      day          = 1
      hour         = 4
      update_track = "stable"
    }

    database_flags {
      name  = "log_checkpoints"
      value = "on"
    }

    database_flags {
      name  = "log_connections"
      value = "on"
    }

    user_labels = var.tags
  }
}

resource "google_sql_database" "main" {
  count = var.cloud_provider == "gcp" ? 1 : 0

  name     = var.database_name
  instance = google_sql_database_instance.main[0].name
}

resource "google_sql_user" "main" {
  count = var.cloud_provider == "gcp" ? 1 : 0

  name     = var.master_username
  instance = google_sql_database_instance.main[0].name
  password = var.master_password
}

# Azure PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "main" {
  count = var.cloud_provider == "azure" ? 1 : 0

  name                   = "${var.project_name}-${var.environment}-db"
  resource_group_name    = var.resource_group_name
  location               = var.region
  version                = var.postgres_version
  delegated_subnet_id    = var.subnet_ids[0]
  private_dns_zone_id    = var.private_dns_zone_id
  administrator_login    = var.master_username
  administrator_password = var.master_password
  zone                   = "1"

  storage_mb = var.storage_size * 1024

  sku_name = var.instance_class

  high_availability {
    mode                      = var.multi_az ? "ZoneRedundant" : "Disabled"
    standby_availability_zone = var.multi_az ? "2" : null
  }

  backup_retention_days = var.backup_retention_days

  tags = var.tags
}

resource "azurerm_postgresql_flexible_server_database" "main" {
  count = var.cloud_provider == "azure" ? 1 : 0

  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.main[0].id
  charset   = "UTF8"
  collation = "en_US.utf8"
}
