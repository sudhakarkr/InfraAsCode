# Development Environment Configuration

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    # Configure your backend
    # bucket = "your-terraform-state-bucket"
    # key    = "dev/terraform.tfstate"
    # region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = local.common_tags
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
}

locals {
  environment = "dev"
  common_tags = {
    Environment = local.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# Networking
module "networking" {
  source = "../../modules/networking"

  cloud_provider     = var.cloud_provider
  project_name       = var.project_name
  environment        = local.environment
  region             = var.cloud_provider == "aws" ? var.aws_region : var.cloud_provider == "gcp" ? var.gcp_region : var.azure_region
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  cluster_name       = "${var.project_name}-${local.environment}"
  enable_nat_gateway = true
  resource_group_name = var.cloud_provider == "azure" ? azurerm_resource_group.main[0].name : ""
  tags               = local.common_tags
}

# Kubernetes Cluster
module "kubernetes" {
  source = "../../modules/kubernetes"

  cloud_provider        = var.cloud_provider
  cluster_name          = "${var.project_name}-${local.environment}"
  kubernetes_version    = var.kubernetes_version
  region                = var.cloud_provider == "aws" ? var.aws_region : var.cloud_provider == "gcp" ? var.gcp_region : var.azure_region
  vpc_id                = module.networking.vpc_id
  subnet_ids            = module.networking.private_subnet_ids
  network_name          = module.networking.gcp_network_name
  subnetwork_name       = module.networking.gcp_subnetwork_name
  project_id            = var.gcp_project_id
  resource_group_name   = var.cloud_provider == "azure" ? azurerm_resource_group.main[0].name : ""
  node_count            = 2
  node_min_count        = 1
  node_max_count        = 5
  node_instance_types   = var.node_instance_types
  spot_instances        = true
  enable_public_access  = true
  tags                  = local.common_tags
}

# Database
module "database" {
  source = "../../modules/database"

  cloud_provider          = var.cloud_provider
  project_name            = var.project_name
  environment             = local.environment
  region                  = var.cloud_provider == "aws" ? var.aws_region : var.cloud_provider == "gcp" ? var.gcp_region : var.azure_region
  vpc_id                  = module.networking.vpc_id
  network_id              = module.networking.vpc_id
  subnet_ids              = module.networking.private_subnet_ids
  resource_group_name     = var.cloud_provider == "azure" ? azurerm_resource_group.main[0].name : ""
  database_name           = var.database_name
  master_username         = var.database_username
  master_password         = var.database_password
  postgres_version        = var.postgres_version
  instance_class          = var.database_instance_class
  storage_size            = 20
  multi_az                = false
  backup_retention_days   = 7
  tags                    = local.common_tags
}

# Azure Resource Group
resource "azurerm_resource_group" "main" {
  count = var.cloud_provider == "azure" ? 1 : 0

  name     = "${var.project_name}-${local.environment}-rg"
  location = var.azure_region

  tags = local.common_tags
}
