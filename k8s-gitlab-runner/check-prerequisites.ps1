# Script to check prerequisites for GitLab Runner deployment

Write-Host "Checking prerequisites for GitLab Runner deployment..." -ForegroundColor Green

# Check if kubectl is installed
try {
    $kubectlVersion = kubectl version --client --short
    Write-Host "✓ kubectl is installed: $kubectlVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ kubectl is not installed or not in PATH" -ForegroundColor Red
    Write-Host "  Please install kubectl: https://kubernetes.io/docs/tasks/tools/install-kubectl/" -ForegroundColor Yellow
}

# Check if Helm is installed
try {
    $helmVersion = helm version --short
    Write-Host "✓ Helm is installed: $helmVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Helm is not installed or not in PATH" -ForegroundColor Red
    Write-Host "  Please install Helm: https://helm.sh/docs/intro/install/" -ForegroundColor Yellow
}

# Check if connected to a Kubernetes cluster
try {
    $clusterInfo = kubectl cluster-info
    Write-Host "✓ Connected to Kubernetes cluster" -ForegroundColor Green
} catch {
    Write-Host "✗ Not connected to a Kubernetes cluster" -ForegroundColor Red
    Write-Host "  Please configure kubectl to connect to your cluster" -ForegroundColor Yellow
}

Write-Host "`nPrerequisites check completed." -ForegroundColor Green