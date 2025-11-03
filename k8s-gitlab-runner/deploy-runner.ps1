# Script to deploy GitLab Runner using Helm

# Variables
$NAMESPACE = "gitlab-runner"
$RELEASE_NAME = "gitlab-runner"
$VALUES_FILE = "values.yaml"

Write-Host "Deploying GitLab Runner to Kubernetes..." -ForegroundColor Green

# Create namespace if it doesn't exist
Write-Host "Creating namespace $NAMESPACE if it doesn't exist..." -ForegroundColor Yellow
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Add GitLab Helm repository
Write-Host "Adding GitLab Helm repository..." -ForegroundColor Yellow
helm repo add gitlab https://charts.gitlab.io

# Update Helm repositories
Write-Host "Updating Helm repositories..." -ForegroundColor Yellow
helm repo update gitlab

# Check available versions
Write-Host "Available GitLab Runner versions:" -ForegroundColor Yellow
helm search repo -l gitlab/gitlab-runner | Select-Object -First 10

# Install GitLab Runner
Write-Host "Installing GitLab Runner..." -ForegroundColor Yellow
helm install --namespace $NAMESPACE $RELEASE_NAME -f $VALUES_FILE gitlab/gitlab-runner

Write-Host "Deployment completed!" -ForegroundColor Green
Write-Host "Check the status with: kubectl get pods -n $NAMESPACE" -ForegroundColor Cyan