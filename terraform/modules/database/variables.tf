variable "cloud_provider" {
  description = "Cloud provider: aws, gcp, or azure"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
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

variable "network_id" {
  description = "VPC network ID (GCP)"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "Subnet IDs for database"
  type        = list(string)
  default     = []
}

variable "resource_group_name" {
  description = "Azure resource group name"
  type        = string
  default     = ""
}

variable "private_dns_zone_id" {
  description = "Azure Private DNS Zone ID"
  type        = string
  default     = ""
}

variable "database_name" {
  description = "Database name"
  type        = string
  default     = "hackathon"
}

variable "master_username" {
  description = "Master username"
  type        = string
  default     = "postgres"
}

variable "master_password" {
  description = "Master password"
  type        = string
  sensitive   = true
}

variable "postgres_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "16"
}

variable "instance_class" {
  description = "Instance class/tier"
  type        = string
  default     = "db.t3.medium"
}

variable "storage_size" {
  description = "Storage size in GB"
  type        = number
  default     = 20
}

variable "max_storage_size" {
  description = "Maximum storage size in GB (AWS)"
  type        = number
  default     = 100
}

variable "multi_az" {
  description = "Enable multi-AZ deployment"
  type        = bool
  default     = false
}

variable "backup_retention_days" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "allowed_security_groups" {
  description = "Security groups allowed to access database (AWS)"
  type        = list(string)
  default     = []
}

variable "monitoring_role_arn" {
  description = "IAM role ARN for enhanced monitoring (AWS)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
