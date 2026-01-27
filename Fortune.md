## Quick Start Guide

### Local Development with Docker Compose

#### Start the application
```bash
cd python-cat
docker-compose up -d
```

#### Test the endpoints
```bash
# Welcome endpoint
curl http://localhost:8000/

# Get a new cat fact (stores in Redis)
curl http://localhost:8000/quote

# List all stored cat facts
curl http://localhost:8000/quotes

# Interactive API docs
open http://localhost:8000/docs
```

#### Stop the application
```bash
docker-compose down
```

---

## Docker Commands

### Build and run manually
```bash
# Build the Docker image
docker build -t python-cat:latest .

# Run Redis container
docker run -d --name redis -p 6379:6379 redis:alpine

# Run the application
docker run -d \
  --name python-cat \
  -p 8000:8000 \
  -e REDIS_HOST=redis \
  --link redis:redis \
  python-cat:latest

# View logs
docker logs -f python-cat

# Stop and remove containers
docker stop python-cat redis
docker rm python-cat redis
```

---

## Kubernetes Deployment

### Deploy to Minikube

#### Apply all manifests
```bash
# Create namespace and deploy everything
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/redis-deployment.yaml
kubectl apply -f k8s/redis-service.yaml
kubectl apply -f k8s/python-cat-deployment.yaml
kubectl apply -f k8s/python-cat-service.yaml

# Or apply all at once
kubectl apply -f k8s/
```

#### Access the service
```bash
# Get the service URL
minikube service python-cat -n python-cat

# Or use port-forward for local access
kubectl port-forward -n python-cat svc/python-cat 8000:8000

# Test the endpoints
curl http://localhost:8000/quote
curl http://localhost:8000/quotes
```

#### Monitor the deployment
```bash
# Watch pods
kubectl get pods -n python-cat -w

# View application logs
kubectl logs -n python-cat -l app=python-cat -f

# View Redis logs
kubectl logs -n python-cat -l app=redis -f

# Describe the deployment
kubectl describe deployment python-cat -n python-cat
```

#### Cleanup
```bash
# Delete all resources
kubectl delete -f k8s/

# Or delete by namespace
kubectl delete namespace python-cat
```

---

## Terraform Infrastructure

### Initialize and deploy AWS infrastructure

```bash
cd tf

# Initialize Terraform
terraform init

# Plan the infrastructure
terraform plan

# Apply the configuration
terraform apply

# Destroy infrastructure when done
terraform destroy
```

---

## Ansible Deployment

### Deploy application to EC2 instances

```bash
cd ansible

# Test connectivity to EC2 instances
ansible all -m ping

# Deploy Minikube
ansible-playbook playbooks/minikube.yml

# Deploy the full application
ansible-playbook site.yml
```

---

## Testing

### Run smoke tests
```bash
cd python-cat
chmod +x smoke_test.sh
./smoke_test.sh
```

### Manual API testing
```bash
# Test root endpoint
curl -s http://localhost:8000/ | jq

# Fetch and store a cat fact
curl -s http://localhost:8000/quote | jq

# Get all stored facts
curl -s http://localhost:8000/quotes | jq

# Multiple requests to populate data
for i in {1..5}; do
  curl -s http://localhost:8000/quote
  echo ""
  sleep 1
done

# View all collected facts
curl -s http://localhost:8000/quotes | jq
```

---

## Troubleshooting

### Check Redis connection
```bash
# Connect to Redis container
docker exec -it redis redis-cli

# In Redis CLI
PING
LRANGE quotes 0 -1
```

### Application debugging
```bash
# Check application logs
docker logs python-cat

# Enter the container
docker exec -it python-cat /bin/bash

# Check Redis connectivity from app
docker exec -it python-cat pip list | grep redis
```

### Kubernetes troubleshooting
```bash
# Check pod status
kubectl get pods -n python-cat

# Describe failing pod
kubectl describe pod <pod-name> -n python-cat

# View events
kubectl get events -n python-cat --sort-by='.lastTimestamp'

# Check service endpoints
kubectl get endpoints -n python-cat

# Test Redis connection from app pod
kubectl exec -it -n python-cat <python-cat-pod> -- /bin/sh
# Inside pod: pip list | grep redis
```

---

## Development Workflow

### Making code changes

1. **Edit the application**
   ```bash
   # Make changes to main.py
   vim python-cat/main.py
   ```

2. **Test locally**
   ```bash
   cd python-cat
   docker-compose up --build
   ```

3. **Run tests**
   ```bash
   ./smoke_test.sh
   ```

4. **Build and tag for deployment**
   ```bash
   docker build -t python-cat:v1.0.0 .
   ```

5. **Update Kubernetes deployment**
   ```bash
   # Update image in deployment manifest
   kubectl set image deployment/python-cat -n python-cat \
     python-cat=python-cat:v1.0.0
   
   # Or apply updated manifest
   kubectl apply -f k8s/python-cat-deployment.yaml
   ```

---

## Environment Variables

### Application Configuration

- `REDIS_HOST`: Redis server hostname (default: `localhost`)
- `REDIS_PORT`: Redis server port (default: `6379`)

### Example .env file for local development
```bash
REDIS_HOST=localhost
REDIS_PORT=6379
```

---

## API Documentation

Once the application is running, access the interactive API documentation:

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
- **OpenAPI JSON**: http://localhost:8000/openapi.json
