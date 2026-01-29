@echo off
REM Minimal deployment script for Grafana Monitoring Stack

REM Add Helm repositories
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts >nul 2>&1
helm repo add grafana https://grafana.github.io/helm-charts >nul 2>&1
helm repo update

REM Create namespace
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f - >nul

REM Deploy components
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack ^
  --version 79.0.1 ^
  --namespace monitoring ^
  --values kube-prometheus-stack-values.yaml ^
  --wait

helm upgrade --install loki grafana/loki ^
  --version 6.45.1 ^
  --namespace monitoring ^
  --values loki-values.yaml ^
  --wait

helm upgrade --install promtail grafana/promtail ^
  --version 6.17.0 ^
  --namespace monitoring ^
  --values promtail-values.yaml ^
  --wait

REM Apply configurations
kubectl apply -f grafana-ingress.yaml -n monitoring >nul 2>&1
kubectl apply -f letsencrypt-clusterissuer.yaml >nul 2>&1

echo Deployment completed!
echo Access Grafana: kubectl --namespace monitoring port-forward svc/kube-prometheus-stack-grafana 3000:80