output "database_endpoint" {
  description = "Database endpoint"
  value = var.cloud_provider == "aws" ? (
    length(aws_db_instance.main) > 0 ? aws_db_instance.main[0].endpoint : null
  ) : var.cloud_provider == "gcp" ? (
    length(google_sql_database_instance.main) > 0 ? google_sql_database_instance.main[0].private_ip_address : null
  ) : var.cloud_provider == "azure" ? (
    length(azurerm_postgresql_flexible_server.main) > 0 ? azurerm_postgresql_flexible_server.main[0].fqdn : null
  ) : null
}

output "database_port" {
  description = "Database port"
  value       = 5432
}

output "database_name" {
  description = "Database name"
  value       = var.database_name
}

output "connection_string" {
  description = "Database connection string"
  sensitive   = true
  value = var.cloud_provider == "aws" ? (
    length(aws_db_instance.main) > 0 ? (
      "jdbc:postgresql://${aws_db_instance.main[0].endpoint}/${var.database_name}"
    ) : null
  ) : var.cloud_provider == "gcp" ? (
    length(google_sql_database_instance.main) > 0 ? (
      "jdbc:postgresql://${google_sql_database_instance.main[0].private_ip_address}:5432/${var.database_name}"
    ) : null
  ) : var.cloud_provider == "azure" ? (
    length(azurerm_postgresql_flexible_server.main) > 0 ? (
      "jdbc:postgresql://${azurerm_postgresql_flexible_server.main[0].fqdn}:5432/${var.database_name}?sslmode=require"
    ) : null
  ) : null
}
