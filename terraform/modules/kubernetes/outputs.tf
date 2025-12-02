output "cluster_name" {
  description = "Kubernetes cluster name"
  value = var.cloud_provider == "aws" ? (
    length(aws_eks_cluster.main) > 0 ? aws_eks_cluster.main[0].name : null
  ) : var.cloud_provider == "gcp" ? (
    length(google_container_cluster.main) > 0 ? google_container_cluster.main[0].name : null
  ) : var.cloud_provider == "azure" ? (
    length(azurerm_kubernetes_cluster.main) > 0 ? azurerm_kubernetes_cluster.main[0].name : null
  ) : null
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint"
  value = var.cloud_provider == "aws" ? (
    length(aws_eks_cluster.main) > 0 ? aws_eks_cluster.main[0].endpoint : null
  ) : var.cloud_provider == "gcp" ? (
    length(google_container_cluster.main) > 0 ? "https://${google_container_cluster.main[0].endpoint}" : null
  ) : var.cloud_provider == "azure" ? (
    length(azurerm_kubernetes_cluster.main) > 0 ? azurerm_kubernetes_cluster.main[0].kube_config[0].host : null
  ) : null
}

output "cluster_ca_certificate" {
  description = "Kubernetes cluster CA certificate"
  sensitive   = true
  value = var.cloud_provider == "aws" ? (
    length(aws_eks_cluster.main) > 0 ? aws_eks_cluster.main[0].certificate_authority[0].data : null
  ) : var.cloud_provider == "gcp" ? (
    length(google_container_cluster.main) > 0 ? google_container_cluster.main[0].master_auth[0].cluster_ca_certificate : null
  ) : var.cloud_provider == "azure" ? (
    length(azurerm_kubernetes_cluster.main) > 0 ? azurerm_kubernetes_cluster.main[0].kube_config[0].cluster_ca_certificate : null
  ) : null
}

output "kubeconfig" {
  description = "Kubeconfig for cluster access"
  sensitive   = true
  value = var.cloud_provider == "azure" && length(azurerm_kubernetes_cluster.main) > 0 ? (
    azurerm_kubernetes_cluster.main[0].kube_config_raw
  ) : null
}
