output "vpc_id" {
  description = "VPC ID"
  value = var.cloud_provider == "aws" ? (
    length(aws_vpc.main) > 0 ? aws_vpc.main[0].id : null
  ) : var.cloud_provider == "gcp" ? (
    length(google_compute_network.main) > 0 ? google_compute_network.main[0].id : null
  ) : var.cloud_provider == "azure" ? (
    length(azurerm_virtual_network.main) > 0 ? azurerm_virtual_network.main[0].id : null
  ) : null
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value = var.cloud_provider == "aws" ? aws_subnet.public[*].id : (
    var.cloud_provider == "azure" ? (
      length(azurerm_subnet.public) > 0 ? [azurerm_subnet.public[0].id] : []
    ) : []
  )
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value = var.cloud_provider == "aws" ? aws_subnet.private[*].id : (
    var.cloud_provider == "azure" ? (
      length(azurerm_subnet.private) > 0 ? [azurerm_subnet.private[0].id] : []
    ) : []
  )
}

output "gcp_network_name" {
  description = "GCP VPC network name"
  value       = var.cloud_provider == "gcp" && length(google_compute_network.main) > 0 ? google_compute_network.main[0].name : null
}

output "gcp_subnetwork_name" {
  description = "GCP subnetwork name"
  value       = var.cloud_provider == "gcp" && length(google_compute_subnetwork.main) > 0 ? google_compute_subnetwork.main[0].name : null
}
