# Infrastructure as Code Boilerplate

Multi-cloud Terraform infrastructure boilerplate for hackathons supporting AWS, Google Cloud, and Azure.

## Features

- **Multi-Cloud Support**: AWS, GCP, and Azure
- **Modular Design**: Reusable modules for networking, Kubernetes, and databases
- **Environment Management**: Dev, staging, and production configurations
- **Security Scanning**: tfsec, checkov, and tflint integration
- **CI/CD Pipelines**: GitHub Actions workflows
- **Testing**: Terratest for infrastructure testing

## Quick Start

### Prerequisites

- Terraform >= 1.6.0
- Cloud CLI tools (aws, gcloud, or az)
- Go (for running tests)

### Initial Setup

1. **Clone and configure**
```bash
git clone <repository-url>
cd InfraAsCode

# Copy example variables
cp terraform/environments/dev/terraform.tfvars.example terraform/environments/dev/terraform.tfvars
```

2. **Edit terraform.tfvars**
```hcl
cloud_provider    = "aws"  # or "gcp" or "azure"
project_name      = "hackathon"
database_password = "YOUR_SECURE_PASSWORD"
```

3. **Initialize and apply**
```bash
cd terraform/environments/dev
terraform init
terraform plan
terraform apply
```

## Project Structure

```
InfraAsCode/
├── terraform/
│   ├── modules/
│   │   ├── networking/     # VPC/VNet configuration
│   │   ├── kubernetes/     # EKS/GKE/AKS setup
│   │   ├── database/       # RDS/Cloud SQL/Azure DB
│   │   └── security/       # Security groups, IAM
│   ├── environments/
│   │   ├── dev/           # Development config
│   │   ├── staging/       # Staging config
│   │   └── prod/          # Production config
│   └── tests/             # Terratest tests
├── scripts/               # Utility scripts
├── .github/workflows/     # CI/CD pipelines
└── docs/                  # Documentation
```

## Modules

### Networking Module
Creates VPC/VNet with public and private subnets, NAT gateways, and route tables.

```hcl
module "networking" {
  source = "../../modules/networking"

  cloud_provider = "aws"
  project_name   = "hackathon"
  environment    = "dev"
  region         = "us-east-1"
  vpc_cidr       = "10.0.0.0/16"
}
```

### Kubernetes Module
Provisions managed Kubernetes clusters (EKS/GKE/AKS) with node groups and autoscaling.

```hcl
module "kubernetes" {
  source = "../../modules/kubernetes"

  cloud_provider      = "aws"
  cluster_name        = "hackathon-dev"
  kubernetes_version  = "1.28"
  node_count          = 3
  node_instance_types = ["t3.medium"]
}
```

### Database Module
Creates managed PostgreSQL instances with backups and security configurations.

```hcl
module "database" {
  source = "../../modules/database"

  cloud_provider    = "aws"
  project_name      = "hackathon"
  database_name     = "hackathon"
  master_username   = "postgres"
  master_password   = var.database_password
  postgres_version  = "16"
}
```

## Cloud-Specific Configuration

### AWS
```hcl
cloud_provider     = "aws"
aws_region         = "us-east-1"
availability_zones = ["us-east-1a", "us-east-1b"]
```

### Google Cloud
```hcl
cloud_provider = "gcp"
gcp_project_id = "your-project-id"
gcp_region     = "us-central1"
```

### Azure
```hcl
cloud_provider        = "azure"
azure_subscription_id = "your-subscription-id"
azure_region          = "eastus"
```

## CI/CD Pipeline

The GitHub Actions workflow provides:

1. **Lint**: terraform fmt and tflint
2. **Security Scan**: tfsec and checkov
3. **Validate**: terraform validate for all environments
4. **Plan**: Generate execution plan
5. **Apply**: Apply changes (manual trigger)
6. **Destroy**: Destroy infrastructure (manual trigger)

### Manual Deployment
```bash
# Via GitHub Actions
# Go to Actions > Terraform CI/CD > Run workflow
# Select environment and action (plan/apply/destroy)
```

## Testing

```bash
cd terraform/tests
go test -v -timeout 30m
```

## Security

- Encryption at rest for databases
- Private subnets for workloads
- NAT gateways for outbound traffic
- Security groups/network policies
- IAM roles with least privilege

## Cost Optimization

### Development
- Single NAT gateway
- Spot instances for nodes
- Smaller instance types
- Minimal storage

### Production
- Multi-AZ deployment
- On-demand instances
- Appropriate instance sizing
- Enhanced monitoring

## License

MIT License
