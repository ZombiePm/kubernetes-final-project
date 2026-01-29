#!/bin/bash

# Script to deploy GitLab Runner using Helm

# Variables
NAMESPACE="gitlab-runner"
RELEASE_NAME="gitlab-runner"
VALUES_FILE="values.yaml"

echo "Deploying GitLab Runner to Kubernetes..."

# Create namespace if it doesn't exist
echo "Creating namespace $NAMESPACE if it doesn't exist..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Add GitLab Helm repository
echo "Adding GitLab Helm repository..."
helm repo add gitlab https://charts.gitlab.io

# Update Helm repositories
echo "Updating Helm repositories..."
helm repo update gitlab

# Check available versions
echo "Available GitLab Runner versions:"
helm search repo -l gitlab/gitlab-runner | head -n 10

# Install GitLab Runner
echo "Installing GitLab Runner..."
helm install --namespace $NAMESPACE $RELEASE_NAME -f $VALUES_FILE gitlab/gitlab-runner

echo "Deployment completed!"
echo "Check the status with: kubectl get pods -n $NAMESPACE"