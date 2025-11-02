# Grafana Monitoring Stack Installation Instructions

This document provides detailed instructions for setting up a unified Grafana monitoring stack with Prometheus metrics and Loki logs in a Kubernetes cluster.

## Prerequisites

1. Kubernetes cluster (1.20+)
2. kubectl configured to access your cluster
3. Helm 3 installed
4. Access to the internet for downloading Helm charts and Docker images

## Architecture Overview

The monitoring stack consists of:
- **kube-prometheus-stack**: Provides Prometheus for metrics collection, Alertmanager for alerting, and Grafana for visualization
- **Loki**: Log aggregation system that serves as the default datasource in Grafana
- **Promtail**: Agent that ships Kubernetes pod logs to Loki
- **Ingress**: Configured with Let's Encrypt TLS certificates for secure external access

## Installation Steps

### 1. Add Helm Repositories

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

### 2. Create Monitoring Namespace

```bash
kubectl create namespace monitoring
```

### 3. Install kube-prometheus-stack

First, review and customize the configuration in `kube-prometheus-stack-values.yaml` if needed, then install:

```bash
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --version 79.0.1 \
  --namespace monitoring \
  --values kube-prometheus-stack-values.yaml
```

This configuration:
- Disables the built-in Grafana (we'll use the one from kube-prometheus-stack)
- Configures Loki as the default datasource
- Sets up appropriate resource limits

### 4. Install Loki

Review and customize the configuration in `loki-values.yaml` if needed, then install:

```bash
helm install loki grafana/loki \
  --version 6.45.1 \
  --namespace monitoring \
  --values loki-values.yaml
```

This configuration:
- Uses Loki v3.5.7 with volume support enabled
- Configures single binary deployment mode for simplicity
- Sets up filesystem storage for logs
- Enables pattern ingestion and structured metadata

### 5. Install Promtail

Review and customize the configuration in `promtail-values.yaml` if needed, then install:

```bash
helm install promtail grafana/promtail \
  --version 6.17.0 \
  --namespace monitoring \
  --values promtail-values.yaml
```

This configuration:
- Ships logs to the Loki service
- Uses appropriate Kubernetes service discovery
- Sets up proper log scraping configurations

### 6. Configure Ingress and TLS

Apply the Ingress configuration:

```bash
kubectl apply -f grafana-ingress.yaml
```

Apply the Let's Encrypt ClusterIssuer:

```bash
kubectl apply -f letsencrypt-clusterissuer.yaml
```

### 7. Verify Installation

Check that all pods are running:

```bash
kubectl --namespace monitoring get pods
```

You should see:
- alertmanager pod (2/2 ready)
- grafana pod (3/3 ready)
- kube-state-metrics pod (1/1 ready)
- prometheus-operator pod (1/1 ready)
- node-exporter pod (1/1 ready)
- loki pod (2/2 ready)
- promtail daemonset pods (1/1 ready)

## Accessing Grafana

### Local Access

To access Grafana locally, set up port forwarding:

```bash
kubectl --namespace monitoring port-forward svc/kube-prometheus-stack-grafana 3000:80
```

Then open http://localhost:3000 in your browser.

Default credentials:
- Username: admin
- Password: prom-operator

### External Access

To access Grafana externally:
1. Configure DNS to point your domain (grafana.csjob.ru) to your cluster's ingress controller IP
2. The Let's Encrypt certificate will be automatically provisioned
3. Access https://grafana.csjob.ru

## Using the Log Volume Feature

With Loki v3.5.7 and the correct configuration, you can now use the log volume features in Grafana:
1. Go to "Explore" in Grafana
2. Select "Loki" as the data source
3. Use the log volume exploration features

## Automated Deployment and Removal

For repeatable deployments, this repository includes minimal scripts:

### Deploy the stack:
```bash
# On Linux/Mac
./deploy-stack.sh

# On Windows
deploy-stack.bat
```

### Remove the stack:
```bash
# On Linux/Mac
./remove-stack.sh

# On Windows
remove-stack.bat
```

## Troubleshooting

### Loki Not Receiving Logs
1. Check Promtail pod logs: `kubectl --namespace monitoring logs -l app.kubernetes.io/name=promtail`
2. Verify Promtail configuration: `kubectl --namespace monitoring get configmap promtail -o yaml`
3. Check Loki readiness: `kubectl --namespace monitoring get pods loki-0`

### Grafana Datasource Issues
1. Verify Loki service is accessible: `kubectl --namespace monitoring exec -it <grafana-pod> -- wget -q -O - http://loki:3100/ready`
2. Check Grafana datasources: In Grafana UI, go to Configuration > Data Sources > Loki

### Ingress Issues
1. Check ingress status: `kubectl --namespace monitoring get ingress grafana`
2. Verify cert-manager is running: `kubectl --namespace cert-manager get pods`
3. Check certificate status: `kubectl --namespace monitoring get certificate grafana-tls`

### Volume Feature Not Working
1. Verify Loki version is 3.2.0 or later
2. Check that `volume_enabled: true` is set in Loki configuration
3. Confirm pattern ingestion and structured metadata are enabled

## Configuration Files

This repository includes the following configuration files:
- `kube-prometheus-stack-values.yaml`: kube-prometheus-stack configuration
- `loki-values.yaml`: Loki configuration with volume support
- `promtail-values.yaml`: Promtail configuration
- `grafana-ingress.yaml`: Ingress configuration for external access
- `letsencrypt-clusterissuer.yaml`: Let's Encrypt ClusterIssuer for TLS certificates
- `deploy-stack.sh` and `deploy-stack.bat`: Deployment scripts
- `remove-stack.sh` and `remove-stack.bat`: Removal scripts

## Security Considerations

1. Change the default Grafana admin password after installation
2. Review and adjust resource limits in the values files for your environment
3. Consider network policies to restrict access to monitoring components
4. Regularly update Helm charts and Docker images

## Customization

You can customize this setup by modifying:
1. The values files for each component
2. The Ingress configuration for different domains
3. The ClusterIssuer for different certificate providers

## Get grafana password  https://grafana.csjob.ru/login
kubectl get secret kube-prometheus-stack-grafana -n monitoring -o json \
  | jq -r '.data | to_entries[] | "\(.key): \(.value|@base64d)"'