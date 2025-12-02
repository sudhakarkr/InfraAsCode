# Agent Quality & Security Guidelines - Infrastructure as Code

## Overview
Guidelines for AI agents and developers working on this Terraform IaC codebase.

## Code Quality Standards

### 1. Terraform Best Practices
- Use modules for reusable components
- Keep resources grouped logically
- Use consistent naming conventions
- Document all variables and outputs
- Version pin providers

### 2. Naming Conventions
```hcl
# Resources: {project}-{environment}-{resource-type}
name = "${var.project_name}-${var.environment}-vpc"

# Variables: snake_case
variable "cluster_name" {}

# Outputs: descriptive with underscores
output "vpc_id" {}
```

### 3. Module Structure
```
modules/
└── module-name/
    ├── main.tf        # Primary resources
    ├── variables.tf   # Input variables
    ├── outputs.tf     # Output values
    ├── versions.tf    # Provider requirements
    └── README.md      # Documentation
```

### 4. Variable Validation
```hcl
variable "environment" {
  type        = string
  description = "Environment name"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

## Security Guidelines

### 1. Secrets Management
- NEVER hardcode secrets
- Use variables with `sensitive = true`
- Store secrets in vault/secrets manager
- Use environment variables for CI/CD

### 2. Network Security
- Use private subnets for workloads
- Implement security groups
- Enable VPC flow logs
- Use NAT for outbound traffic

### 3. IAM Best Practices
- Least privilege principle
- Use roles over users
- Enable MFA where possible
- Regular access reviews

### 4. Encryption
- Enable encryption at rest
- Use TLS for transit
- Rotate encryption keys
- Store keys securely

### 5. Security Checklist
- [ ] No hardcoded secrets
- [ ] Private subnets for databases
- [ ] Encryption enabled
- [ ] Security groups restrictive
- [ ] IAM roles least privilege
- [ ] Logging enabled

## Testing Requirements

### 1. Static Analysis
```bash
# Format check
terraform fmt -check -recursive

# Linting
tflint --recursive

# Security scan
tfsec .
checkov -d .
```

### 2. Validation
```bash
terraform init
terraform validate
terraform plan
```

### 3. Integration Tests
- Use Terratest for Go-based tests
- Test resource creation
- Validate outputs
- Clean up resources

## CI/CD Guidelines

### 1. Pipeline Stages
1. Lint & format
2. Security scanning
3. Validate all environments
4. Plan (PR review)
5. Apply (after approval)

### 2. State Management
- Use remote state (S3, GCS, Azure Blob)
- Enable state locking
- Encrypt state files
- Separate state per environment

### 3. Branching Strategy
```
main          - Production state
develop       - Integration
feature/*     - New features
hotfix/*      - Production fixes
```

## Quick Reference Commands

```bash
# Initialize
terraform init

# Format
terraform fmt -recursive

# Validate
terraform validate

# Plan
terraform plan -out=tfplan

# Apply
terraform apply tfplan

# Destroy
terraform destroy

# State management
terraform state list
terraform state show <resource>

# Import existing
terraform import <resource> <id>
```

## Common Issues

### State Locking
```bash
# Force unlock (use carefully)
terraform force-unlock <lock-id>
```

### Provider Issues
```bash
# Clear provider cache
rm -rf .terraform
terraform init
```

### Plan Changes
- Review all changes before apply
- Use `-target` for specific resources
- Check for resource recreation

## Contact & Support

- Create GitHub issues
- Check Terraform documentation
- Review cloud provider docs
