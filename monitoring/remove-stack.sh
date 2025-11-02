#!/bin/bash
# Minimal removal script for Grafana Monitoring Stack

# Remove Helm releases
helm --namespace monitoring uninstall kube-prometheus-stack loki promtail 2>/dev/null || true

# Remove configurations
kubectl delete -f grafana-ingress.yaml -n monitoring --ignore-not-found=true
kubectl delete -f letsencrypt-clusterissuer.yaml --ignore-not-found=true

echo "Removal completed!"
echo "To remove namespace: kubectl delete namespace monitoring"
