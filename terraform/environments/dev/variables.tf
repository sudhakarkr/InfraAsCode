variable "cloud_provider" {
  description = "Cloud provider to use: aws, gcp, or azure"
  type        = string
  default     = "aws"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "hackathon"
}

# AWS Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "availability_zones" {
  description = "AWS availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

# GCP Variables
variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
  default     = ""
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

# Azure Variables
variable "azure_subscription_id" {
  description = "Azure subscription ID"
  type        = string
  default     = ""
}

variable "azure_region" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

# Networking
variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

# Kubernetes
variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}

variable "node_instance_types" {
  description = "Instance types for Kubernetes nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

# Database
variable "database_name" {
  description = "Database name"
  type        = string
  default     = "hackathon"
}

variable "database_username" {
  description = "Database master username"
  type        = string
  default     = "postgres"
}

variable "database_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "postgres_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "16"
}

variable "database_instance_class" {
  description = "Database instance class"
  type        = string
  default     = "db.t3.small"
}
