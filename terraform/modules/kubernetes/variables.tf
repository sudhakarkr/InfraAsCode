variable "cloud_provider" {
  description = "Cloud provider: aws, gcp, or azure"
  type        = string
}

variable "cluster_name" {
  description = "Kubernetes cluster name"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}

variable "region" {
  description = "Cloud region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID (AWS)"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "Subnet IDs for nodes"
  type        = list(string)
  default     = []
}

variable "network_name" {
  description = "VPC network name (GCP)"
  type        = string
  default     = ""
}

variable "subnetwork_name" {
  description = "Subnetwork name (GCP)"
  type        = string
  default     = ""
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
  default     = ""
}

variable "resource_group_name" {
  description = "Azure resource group name"
  type        = string
  default     = ""
}

variable "node_count" {
  description = "Initial node count"
  type        = number
  default     = 3
}

variable "node_min_count" {
  description = "Minimum node count for autoscaling"
  type        = number
  default     = 1
}

variable "node_max_count" {
  description = "Maximum node count for autoscaling"
  type        = number
  default     = 10
}

variable "node_instance_types" {
  description = "Instance types for nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "spot_instances" {
  description = "Use spot/preemptible instances"
  type        = bool
  default     = false
}

variable "enable_public_access" {
  description = "Enable public access to API server"
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "Azure Log Analytics Workspace ID"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
