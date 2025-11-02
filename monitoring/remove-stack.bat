@echo off
REM Minimal removal script for Grafana Monitoring Stack

REM Remove Helm releases
helm --namespace monitoring uninstall kube-prometheus-stack loki promtail 2>nul

REM Remove configurations
kubectl delete -f grafana-ingress.yaml -n monitoring --ignore-not-found=true >nul 2>&1
kubectl delete -f letsencrypt-clusterissuer.yaml --ignore-not-found=true >nul 2>&1

echo Removal completed!
echo To remove namespace: kubectl delete namespace monitoring
