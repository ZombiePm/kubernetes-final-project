# GitLab Runner Deployment with Helm

This repository contains the necessary configuration files to deploy GitLab Runner on Kubernetes using the official Helm chart.

## Prerequisites

- Kubernetes 1.4+ with beta APIs enabled
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) CLI installed and configured
- [Helm](https://helm.sh/docs/intro/install/) CLI installed
- Access to a GitLab instance (GitLab.com or self-managed)

## Installation

1. **Add the GitLab Helm repository:**
   ```bash
   helm repo add gitlab https://charts.gitlab.io
   ```

2. **Update the Helm chart repositories:**
   ```bash
   helm repo update gitlab
   ```

3. **Configure GitLab Runner:**
   
   Edit the `values.yaml` file to set your configuration:
   - Set `gitlabUrl` to your GitLab instance URL
   - Obtain a runner token from your GitLab instance and set `runnerToken`
   - Adjust other settings as needed

4. **Install GitLab Runner:**

   For Helm 3:
   ```bash
   helm install --namespace gitlab-runner gitlab-runner -f values.yaml gitlab/gitlab-runner
   ```

   For Helm 2:
   ```bash
   helm install --namespace gitlab-runner --name gitlab-runner -f values.yaml gitlab/gitlab-runner
   ```

## Upgrade

To upgrade your GitLab Runner installation:

```bash
helm upgrade --namespace gitlab-runner -f values.yaml gitlab-runner gitlab/gitlab-runner
```

## Uninstall

To uninstall GitLab Runner:

```bash
helm delete --namespace gitlab-runner gitlab-runner
```

## Configuration

Refer to the [official GitLab Runner Helm chart documentation](https://docs.gitlab.com/runner/install/kubernetes.html) for all available configuration options.