# Networking Module - Multi-Cloud VPC/VNet Setup

terraform {
  required_version = ">= 1.6.0"
}

# AWS VPC
resource "aws_vpc" "main" {
  count = var.cloud_provider == "aws" ? 1 : 0

  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-vpc"
  })
}

resource "aws_subnet" "public" {
  count = var.cloud_provider == "aws" ? length(var.availability_zones) : 0

  vpc_id                  = aws_vpc.main[0].id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name                                           = "${var.project_name}-${var.environment}-public-${count.index + 1}"
    "kubernetes.io/role/elb"                       = "1"
    "kubernetes.io/cluster/${var.cluster_name}"    = "shared"
  })
}

resource "aws_subnet" "private" {
  count = var.cloud_provider == "aws" ? length(var.availability_zones) : 0

  vpc_id            = aws_vpc.main[0].id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index + length(var.availability_zones))
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.tags, {
    Name                                           = "${var.project_name}-${var.environment}-private-${count.index + 1}"
    "kubernetes.io/role/internal-elb"              = "1"
    "kubernetes.io/cluster/${var.cluster_name}"    = "shared"
  })
}

resource "aws_internet_gateway" "main" {
  count = var.cloud_provider == "aws" ? 1 : 0

  vpc_id = aws_vpc.main[0].id

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-igw"
  })
}

resource "aws_eip" "nat" {
  count = var.cloud_provider == "aws" && var.enable_nat_gateway ? length(var.availability_zones) : 0

  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-nat-eip-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "main" {
  count = var.cloud_provider == "aws" && var.enable_nat_gateway ? length(var.availability_zones) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-nat-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table" "public" {
  count = var.cloud_provider == "aws" ? 1 : 0

  vpc_id = aws_vpc.main[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main[0].id
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-public-rt"
  })
}

resource "aws_route_table" "private" {
  count = var.cloud_provider == "aws" && var.enable_nat_gateway ? length(var.availability_zones) : 0

  vpc_id = aws_vpc.main[0].id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-private-rt-${count.index + 1}"
  })
}

resource "aws_route_table_association" "public" {
  count = var.cloud_provider == "aws" ? length(var.availability_zones) : 0

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table_association" "private" {
  count = var.cloud_provider == "aws" && var.enable_nat_gateway ? length(var.availability_zones) : 0

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# GCP VPC
resource "google_compute_network" "main" {
  count = var.cloud_provider == "gcp" ? 1 : 0

  name                    = "${var.project_name}-${var.environment}-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "main" {
  count = var.cloud_provider == "gcp" ? 1 : 0

  name          = "${var.project_name}-${var.environment}-subnet"
  ip_cidr_range = var.vpc_cidr
  region        = var.region
  network       = google_compute_network.main[0].id

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.pods_cidr
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = var.services_cidr
  }

  private_ip_google_access = true
}

resource "google_compute_router" "main" {
  count = var.cloud_provider == "gcp" && var.enable_nat_gateway ? 1 : 0

  name    = "${var.project_name}-${var.environment}-router"
  region  = var.region
  network = google_compute_network.main[0].id
}

resource "google_compute_router_nat" "main" {
  count = var.cloud_provider == "gcp" && var.enable_nat_gateway ? 1 : 0

  name                               = "${var.project_name}-${var.environment}-nat"
  router                             = google_compute_router.main[0].name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Azure VNet
resource "azurerm_virtual_network" "main" {
  count = var.cloud_provider == "azure" ? 1 : 0

  name                = "${var.project_name}-${var.environment}-vnet"
  location            = var.region
  resource_group_name = var.resource_group_name
  address_space       = [var.vpc_cidr]

  tags = var.tags
}

resource "azurerm_subnet" "public" {
  count = var.cloud_provider == "azure" ? 1 : 0

  name                 = "${var.project_name}-${var.environment}-public-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main[0].name
  address_prefixes     = [cidrsubnet(var.vpc_cidr, 4, 0)]
}

resource "azurerm_subnet" "private" {
  count = var.cloud_provider == "azure" ? 1 : 0

  name                 = "${var.project_name}-${var.environment}-private-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main[0].name
  address_prefixes     = [cidrsubnet(var.vpc_cidr, 4, 1)]
}
