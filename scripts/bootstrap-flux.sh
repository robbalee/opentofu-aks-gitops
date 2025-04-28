#!/bin/bash
# Bootstrap Flux on AKS cluster

set -e

ENVIRONMENT=${1:-dev}
GITHUB_USER=${2:-""}
GITHUB_REPO=${3:-""}

if [ -z "$GITHUB_USER" ] || [ -z "$GITHUB_REPO" ]; then
  echo "Usage: $0 <environment> <github-user> <github-repo>"
  echo "Example: $0 dev myuser opentofu-aks-gitops"
  exit 1
fi

echo "Bootstrapping Flux for environment: $ENVIRONMENT"

# Get AKS cluster info
cd infrastructure/environments/$ENVIRONMENT
CLUSTER_NAME=$(tofu output -json | jq -r '.aks_cluster_name.value')

if [ -z "$CLUSTER_NAME" ]; then
  echo "Error: Failed to get AKS cluster name from OpenTofu outputs"
  exit 1
fi

# Get AKS credentials
echo "Getting credentials for AKS cluster: $CLUSTER_NAME"
az aks get-credentials --name $CLUSTER_NAME --resource-group "rg-aksflux-${ENVIRONMENT}" --overwrite-existing

# Check if GITHUB_TOKEN is set
if [ -z "$GITHUB_TOKEN" ]; then
  echo "Error: GITHUB_TOKEN environment variable is not set"
  echo "Please set it with: export GITHUB_TOKEN=your-github-token"
  exit 1
fi

# Bootstrap Flux
echo "Installing Flux on AKS cluster: $CLUSTER_NAME"
flux bootstrap github \
  --owner=$GITHUB_USER \
  --repository=$GITHUB_REPO \
  --branch=main \
  --path=./kubernetes/clusters/$ENVIRONMENT \
  --personal

echo "Flux bootstrap complete for $ENVIRONMENT environment"
echo "Your GitOps workflow is now set up!"
