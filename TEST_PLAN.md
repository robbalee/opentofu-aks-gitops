# OpenTofu AKS GitOps Testing Plan

This document outlines the approach to testing the OpenTofu AKS GitOps project without deploying resources to Azure.

## 1. Pre-Deployment Validation

### 1.1. OpenTofu Configuration Validation

```bash
# Validate OpenTofu configuration in each environment
make validate
make validate-dev
make validate-staging
make validate-prod
```

### 1.2. OpenTofu Plan Validation

```bash
# Generate and review execution plans for each environment
make plan-dev
make plan-staging
make plan-prod
```

### 1.3. OpenTofu Format Check

```bash
# Check OpenTofu code formatting
make fmt-check
```

## 2. Kubernetes Manifests Testing

### 2.1. Kustomize Build Validation

```bash
# Validate that Kustomize can build manifests for each environment
kustomize build kubernetes/clusters/dev
kustomize build kubernetes/clusters/staging
kustomize build kubernetes/clusters/prod
```

### 2.2. Kubernetes Manifest Validation

```bash
# Validate Kubernetes manifests using kubectl
for env in dev staging prod; do
  kustomize build kubernetes/clusters/$env | kubectl apply --dry-run=client -f -
done
```

### 2.3. Kustomize Diff

```bash
# Compare differences between environments
diff -u <(kustomize build kubernetes/clusters/dev) <(kustomize build kubernetes/clusters/staging)
diff -u <(kustomize build kubernetes/clusters/staging) <(kustomize build kubernetes/clusters/prod)
```

## 3. GitOps Configuration Testing

### 3.1. Flux Validation

```bash
# Validate Flux manifests
flux check --pre
```

### 3.2. Flux Manifest Diff

```bash
# Validate flux manifests differences between environments
diff -u <(kustomize build kubernetes/clusters/dev/flux-system) <(kustomize build kubernetes/clusters/staging/flux-system)
diff -u <(kustomize build kubernetes/clusters/staging/flux-system) <(kustomize build kubernetes/clusters/prod/flux-system)
```

## 4. Script Testing

### 4.1. Shell Script Validation

```bash
# Check shell scripts for syntax errors
shellcheck scripts/*.sh
```

### 4.2. Script Dry Runs

```bash
# Perform dry runs of scripts where possible
bash -n scripts/*.sh
```

## 5. Local Kubernetes Testing (Optional)

If a local Kubernetes cluster (e.g., Kind, Minikube) is available:

```bash
# Deploy to local Kubernetes for testing
kustomize build kubernetes/clusters/dev | kubectl apply -f -
```

## 6. Continuous Integration Tests

Add the following tests to CI pipelines:

1. OpenTofu validation and format checks
2. Kustomize build validation
3. Kubernetes manifest validation
4. Shell script linting

## Test Execution Checklist

- [ ] OpenTofu validation successful for all environments
- [ ] OpenTofu plan review completed
- [ ] Kustomize builds successfully for all environments
- [ ] Kubernetes manifests pass validation
- [ ] Flux configuration validated
- [ ] Shell scripts pass syntax checking
- [ ] Environment diff reviews completed
