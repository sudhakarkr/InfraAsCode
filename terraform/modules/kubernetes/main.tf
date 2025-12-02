# Kubernetes Module - Multi-Cloud EKS/GKE/AKS

terraform {
  required_version = ">= 1.6.0"
}

# AWS EKS
resource "aws_eks_cluster" "main" {
  count = var.cloud_provider == "aws" ? 1 : 0

  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster[0].arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = var.enable_public_access
    security_group_ids      = [aws_security_group.eks_cluster[0].id]
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  tags = merge(var.tags, {
    Name = var.cluster_name
  })

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_vpc_resource_controller,
  ]
}

resource "aws_eks_node_group" "main" {
  count = var.cloud_provider == "aws" ? 1 : 0

  cluster_name    = aws_eks_cluster.main[0].name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.eks_nodes[0].arn
  subnet_ids      = var.subnet_ids

  instance_types = var.node_instance_types
  capacity_type  = var.spot_instances ? "SPOT" : "ON_DEMAND"

  scaling_config {
    desired_size = var.node_count
    max_size     = var.node_max_count
    min_size     = var.node_min_count
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "worker"
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-node-group"
  })

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry,
  ]
}

# AWS IAM Roles
resource "aws_iam_role" "eks_cluster" {
  count = var.cloud_provider == "aws" ? 1 : 0

  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  count = var.cloud_provider == "aws" ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster[0].name
}

resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
  count = var.cloud_provider == "aws" ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster[0].name
}

resource "aws_iam_role" "eks_nodes" {
  count = var.cloud_provider == "aws" ? 1 : 0

  name = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  count = var.cloud_provider == "aws" ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes[0].name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  count = var.cloud_provider == "aws" ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes[0].name
}

resource "aws_iam_role_policy_attachment" "eks_container_registry" {
  count = var.cloud_provider == "aws" ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes[0].name
}

resource "aws_security_group" "eks_cluster" {
  count = var.cloud_provider == "aws" ? 1 : 0

  name        = "${var.cluster_name}-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-cluster-sg"
  })
}

# GCP GKE
resource "google_container_cluster" "main" {
  count = var.cloud_provider == "gcp" ? 1 : 0

  name     = var.cluster_name
  location = var.region

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.network_name
  subnetwork = var.subnetwork_name

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  release_channel {
    channel = "REGULAR"
  }

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
  }
}

resource "google_container_node_pool" "main" {
  count = var.cloud_provider == "gcp" ? 1 : 0

  name       = "${var.cluster_name}-node-pool"
  location   = var.region
  cluster    = google_container_cluster.main[0].name
  node_count = var.node_count

  autoscaling {
    min_node_count = var.node_min_count
    max_node_count = var.node_max_count
  }

  node_config {
    machine_type = var.node_instance_types[0]
    disk_size_gb = 100
    disk_type    = "pd-standard"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      role = "worker"
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

# Azure AKS
resource "azurerm_kubernetes_cluster" "main" {
  count = var.cloud_provider == "azure" ? 1 : 0

  name                = var.cluster_name
  location            = var.region
  resource_group_name = var.resource_group_name
  dns_prefix          = var.cluster_name
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                = "default"
    node_count          = var.node_count
    vm_size             = var.node_instance_types[0]
    vnet_subnet_id      = var.subnet_ids[0]
    enable_auto_scaling = true
    min_count           = var.node_min_count
    max_count           = var.node_max_count

    node_labels = {
      role = "worker"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    network_policy    = "calico"
  }

  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  tags = var.tags
}
