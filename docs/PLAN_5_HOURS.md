# 5-Hour Infrastructure Implementation Plan

Focused plan for deploying infrastructure in 5 hours.

## Pre-Event
- Cloud account configured
- CLI tools installed
- Repository cloned

---

## Hour 1: Setup & Networking (60 min)

### 1.1 Quick Setup (15 min)
```bash
cd InfraAsCode/terraform/environments/dev
cp terraform.tfvars.example terraform.tfvars
# Edit variables
```

### 1.2 Initialize (10 min)
```bash
terraform init
terraform validate
```

### 1.3 Deploy Network (35 min)
```bash
terraform plan -target=module.networking
terraform apply -target=module.networking -auto-approve
```

**Checkpoint:** VPC created, subnets available

---

## Hour 2: Kubernetes Cluster (60 min)

### 2.1 Deploy Cluster (50 min)
```bash
terraform apply -target=module.kubernetes -auto-approve
```

### 2.2 Configure kubectl (10 min)
```bash
aws eks update-kubeconfig --name <cluster-name>
kubectl get nodes
```

**Checkpoint:** Cluster running, nodes ready

---

## Hour 3: Database & Secrets (60 min)

### 3.1 Deploy Database (40 min)
```bash
terraform apply -target=module.database -auto-approve
```

### 3.2 Create Secrets (20 min)
```bash
kubectl create namespace hackathon
kubectl create secret generic db-credentials \
  -n hackathon \
  --from-literal=url="$(terraform output -raw database_connection_string)" \
  --from-literal=username=postgres \
  --from-literal=password="$DB_PASSWORD"
```

**Checkpoint:** Database running, secrets created

---

## Hour 4: Application Deployment (60 min)

### 4.1 Deploy Applications (40 min)
```bash
kubectl apply -k k8s/overlays/dev
kubectl wait --for=condition=available deployment/api -n hackathon --timeout=300s
```

### 4.2 Verify Deployment (20 min)
```bash
kubectl get pods -n hackathon
kubectl logs deployment/api -n hackathon
```

**Checkpoint:** Applications running

---

## Hour 5: Testing & Documentation (60 min)

### 5.1 Test Endpoints (20 min)
```bash
kubectl port-forward svc/api 8080:80 -n hackathon &
curl http://localhost:8080/api/v1/health
```

### 5.2 Document Outputs (20 min)
```bash
terraform output > infrastructure-outputs.txt
```

### 5.3 Commit & Share (20 min)
```bash
git add .
git commit -m "infra: deploy hackathon infrastructure"
```

---

## Essential Checklist

- [ ] Network deployed
- [ ] Cluster running
- [ ] Database accessible
- [ ] Applications deployed
- [ ] Endpoints working

---

## Shortcuts

1. **Skip NAT Gateway**: Set `enable_nat_gateway = false` for dev
2. **Reduce nodes**: Use `node_count = 2`
3. **Parallel apply**: Run full `terraform apply` instead of targeted

---

## Commands Cheat Sheet

```bash
# All-in-one deployment
terraform apply -auto-approve

# Quick status
kubectl get all -n hackathon

# Logs
kubectl logs -f deployment/api -n hackathon

# Port forward
kubectl port-forward svc/api 8080:80 -n hackathon
```
