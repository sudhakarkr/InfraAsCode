output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "cluster_name" {
  description = "Kubernetes cluster name"
  value       = module.kubernetes.cluster_name
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint"
  value       = module.kubernetes.cluster_endpoint
}

output "database_endpoint" {
  description = "Database endpoint"
  value       = module.database.database_endpoint
}

output "database_connection_string" {
  description = "Database connection string"
  value       = module.database.connection_string
  sensitive   = true
}
