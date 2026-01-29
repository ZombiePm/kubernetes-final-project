#!/bin/bash
# Minimal deployment script for Grafana Monitoring Stack

set -e

# Add Helm repositories
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts 2>/dev/null || true
helm repo add grafana https://grafana.github.io/helm-charts 2>/dev/null || true
helm repo update

# Create namespace
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Deploy components
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --version 79.0.1 \
  --namespace monitoring \
  --values kube-prometheus-stack-values.yaml \
  --wait

helm upgrade --install loki grafana/loki \
  --version 6.45.1 \
  --namespace monitoring \
  --values loki-values.yaml \
  --wait

helm upgrade --install promtail grafana/promtail \
  --version 6.17.0 \
  --namespace monitoring \
  --values promtail-values.yaml \
  --wait

# Apply configurations
kubectl apply -f grafana-ingress.yaml -n monitoring
kubectl apply -f letsencrypt-clusterissuer.yaml

echo "Deployment completed!"
echo "Access Grafana: kubectl --namespace monitoring port-forward svc/kube-prometheus-stack-grafana 3000:80"