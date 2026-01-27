# Python Cat - Cat Facts API

A complete end-to-end deployment solution for a Python FastAPI application with Infrastructure as Code (IaC), containerization, and Kubernetes orchestration.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
  - [AWS Infrastructure Overview](#aws-infrastructure-overview)
  - [K8s Infrastructure Overview](#k8s-infrastructure-overview)
  - [CI/CD overview](#cicd-overview)
- [Project Structure](#project-structure)
- [Components](#components)
  - [Python Application](#python-application)
  - [Infrastructure (Terraform)](#infrastructure-terraform)
  - [Kubernetes Manifests](#kubernetes-manifests)
- [Monitoring & Testing](#monitoring--testing)
  - [Health Checks](#health-checks)
- [Future Improvements](#-future-improvements)
  - [Recommended Production Enhancements](#recommended-production-enhancements)

## 🎯 Overview

This repository contains a production-ready deployment pipeline for a Python FastAPI-based Cat Facts API. The application provides RESTful endpoints for fetching and storing cat facts, backed by Redis for data persistence.

### Key Features

- **FastAPI Application**: RESTful API with automatic Swagger documentation
- **Infrastructure as Code**: Terraform configurations for AWS resources
- **Container Orchestration**: Kubernetes deployment with Redis backend
- **Configuration Management**: Ansible playbooks for automated setup
- **Local Development**: Docker Compose for local development
- **Redis Integration**: Persistent storage for cat facts

## 🏗️ Architecture

### CI/CD overview

1. **Development**: Developers create feature branches and push code changes. Smoke tests run automatically on feature and dev branches

2. **Pull Request**: Create a PR for code review. Terraform plan runs automatically if infrastructure files change (workflow_dispatch also available)

3. **Merge to Main**: After approval, merge triggers Terraform Apply to update AWS infrastructure (if needed)

4. **Tag & Release**: Create a version tag (e.g., `v1.0.0`) which automatically triggers:
   - Docker image build and push to container registry
   - Kubernetes manifest validation
   - GitHub Release creation with artifacts

5. **Deployment**: Manually trigger deployment via Ansible, which:
   - Connects to EC2 instances via AWS Systems Manager
   - Deploys the application to Minikube cluster

### AWS Infrastructure Overview

The infrastructure consists of:
- VPC with public/private subnets
- EC2 instances running Kubernetes (Minikube)
- Security groups for network isolation
- IAM roles for AWS service access

### K8s Infrastructure Overview

The Kubernetes cluster architecture includes:
- Python FastAPI application deployment with multiple replicas
- Redis deployment for data persistence
- LoadBalancer/NodePort services for external access
- Namespace isolation for resource organization

## 📁 Project Structure

```
.
├── python-cat/              # FastAPI application source code
│   ├── main.py             # FastAPI app entry point
│   ├── requirements.txt    # Python dependencies
│   ├── Dockerfile          # Container image definition
│   ├── docker-compose.yml  # Local development setup
│   └── smoke_test.sh       # Smoke tests
│
├── k8s/                     # Kubernetes manifests
│   ├── namespace.yaml      # Namespace definition
│   ├── python-cat-deployment.yaml
│   ├── python-cat-service.yaml
│   ├── redis-deployment.yaml
│   └── redis-service.yaml
│
├── tf/                      # Terraform configurations
│   ├── vpc.tf              # Network infrastructure
│   ├── compute.tf          # Compute resources
│   ├── provider.tf         # AWS provider config
│   ├── backend.tf          # Terraform backend config
│   └── vars.tf             # Variable definitions
│
└── ansible/                 # Ansible automation
    ├── site.yml            # Main playbook
    ├── playbooks/          # Specific playbooks
    └── aws_ec2.yml         # Dynamic inventory

```

## 🔨 Components

### Python Application

A FastAPI-based REST API providing cat facts functionality:

**Endpoints:**
- `GET /` - Welcome message and available endpoints
- `GET /quote` - Fetch a new cat fact and store it in Redis
- `GET /quotes` - Retrieve all stored cat facts
- `GET /docs` - Interactive Swagger API documentation
- `GET /redoc` - ReDoc API documentation

**Features:**
- Fetches cat facts from external API (catfact.ninja)
- Stores facts in Redis with cute cat emojis 🐱
- Fast and efficient with async support
- Automatic API documentation

### Infrastructure (Terraform)

Terraform modules for provisioning AWS infrastructure:

- **VPC**: Network infrastructure with subnets and routing
- **Compute**: EC2 instances for running Minikube
- **Backend**: S3 backend for Terraform state management
- **Cloud-init**: Automated instance configuration

### Kubernetes Manifests

#### Python Cat Deployment
- Configurable replicas for high availability
- NodePort service for external access
- Environment variables for Redis connection
- Health check endpoints

#### Redis Deployment
- Single replica deployment for data storage
- ClusterIP service for internal access
- Persistent data storage for cat facts

## 🧪 Monitoring & Testing

### Health Checks

```bash
# Access the service via Minikube
minikube service python-cat -n python-cat

# Test endpoints directly (replace IP with your cluster IP)
curl http://192.168.49.2:30080/
curl http://192.168.49.2:30080/quote
curl http://192.168.49.2:30080/quotes

# Check Kubernetes pods
kubectl get pods -n python-cat -w

# View application logs
kubectl logs -n python-cat -l app=python-cat -f

# View Redis logs
kubectl logs -n python-cat -l app=redis -f

# Port forward for local testing
kubectl port-forward -n python-cat svc/python-cat 8000:8000
curl http://localhost:8000/quote
```

### Local Development

```bash
# Run with Docker Compose
cd python-cat
docker-compose up

# Test locally
curl http://localhost:8000/quote
curl http://localhost:8000/quotes

# Run smoke tests
./smoke_test.sh
```

## 🔮 Future Improvements

### Recommended Production Enhancements

1. **Repository Management**
   - Split Terraform, Kubernetes manifests, and Python app into separate repositories
   - Implement GitOps workflow (ArgoCD/FluxCD)
   - Version control for Kubernetes manifests

2. **Compute**
   - Migrate from self-managed Minikube to managed Kubernetes (AWS EKS)
   - Implement auto-scaling for both application and infrastructure

3. **Container Registry**
   - Migrate to AWS ECR for native EKS integration
   - Implement image scanning and vulnerability assessment
   - Add image signing for security

4. **Environment Strategy**
   - Implement proper dev/staging/prod environments with isolated clusters
   - Implement promotion gates with automated testing between environments
   - Use environment-based namespaces and resource quotas
   - Separate Redis instances per environment

5. **CI/CD Enhancements**
   - Build once, promote across environments (dev → staging → prod)
   - Implement blue-green or canary deployment strategies
   - Automate the entire deployment pipeline
   - Add automated integration tests in pipeline

6. **Rollback & Recovery**
   - Define rollback strategy for failed deployments
   - Implement automated backup for Redis data
   - Add disaster recovery procedures

7. **Resource Management**
   - Define CPU and memory requests/limits for all pods
   - Implement Pod Disruption Budgets (PDB) for high availability
   - Deploy monitoring agent (Prometheus, Datadog, or CloudWatch agent)
   - Implement Horizontal Pod Autoscaler (HPA)

8. **Network & Security Policies**
   - Implement NetworkPolicies to control pod-to-pod communication
   - Define egress and ingress rules for application pods
   - Restrict Redis access to application pods only
   - Add TLS/SSL for external endpoints

9. **Data Persistence**
   - Implement Redis persistence with PersistentVolumeClaims
   - Add Redis replication for high availability
   - Consider Redis Cluster or managed Redis (AWS ElastiCache)
   - Implement backup and restore procedures

10. **Observability**
    - Add Prometheus metrics endpoint
    - Integrate with ELK stack or CloudWatch Logs
    - Implement distributed tracing (Jaeger/X-Ray)
    - Add custom metrics for cat fact fetches and storage
    - Implement alerting for Redis connection failures

11. **Testing**
    - Add comprehensive unit tests
    - Implement integration tests for Redis operations
    - Add load testing with k6 or Locust
    - Implement chaos engineering tests
    - Add security scanning in CI pipeline

12. **API Improvements**
    - Add rate limiting to prevent API abuse
    - Implement caching layer for external API calls
    - Add authentication/authorization if needed
    - Implement request validation and error handling
    - Add API versioning strategy


