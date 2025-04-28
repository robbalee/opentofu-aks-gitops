#!/bin/bash
# Setup script for OpenTofu AKS GitOps project

set -e

ENVIRONMENT=${1:-dev}
PROJECT_NAME=${2:-aksflux}
LOCATION=${3:-eastus}

echo "Initializing OpenTofu for environment: $ENVIRONMENT"

# Create Azure Resource Group for state storage
echo "Creating resource group for state storage..."
az group create --name "rg-${PROJECT_NAME}-tfstate" --location $LOCATION

# Create Azure Storage Account for state storage
STORAGE_ACCOUNT_NAME="${PROJECT_NAME}tfstate$RANDOM"
echo "Creating storage account: $STORAGE_ACCOUNT_NAME..."
az storage account create \
    --name $STORAGE_ACCOUNT_NAME \
    --resource-group "rg-${PROJECT_NAME}-tfstate" \
    --location $LOCATION \
    --sku Standard_LRS \
    --encryption-services blob

# Create Azure Storage Container for state storage
echo "Creating storage container for OpenTofu state..."
az storage container create \
    --name "tfstate" \
    --account-name $STORAGE_ACCOUNT_NAME

# Get Storage Account Key
STORAGE_ACCOUNT_KEY=$(az storage account keys list \
    --resource-group "rg-${PROJECT_NAME}-tfstate" \
    --account-name $STORAGE_ACCOUNT_NAME \
    --query '[0].value' -o tsv)

# Initialize OpenTofu with remote state
cd infrastructure/environments/$ENVIRONMENT
tofu init \
    -backend-config="resource_group_name=rg-${PROJECT_NAME}-tfstate" \
    -backend-config="storage_account_name=$STORAGE_ACCOUNT_NAME" \
    -backend-config="container_name=tfstate" \
    -backend-config="key=${ENVIRONMENT}.tfstate" \
    -backend-config="access_key=$STORAGE_ACCOUNT_KEY"

echo "OpenTofu initialization complete for $ENVIRONMENT environment"
echo "Storage Account: $STORAGE_ACCOUNT_NAME"
echo ""
echo "You can now run: tofu plan -out=tfplan"
echo "Followed by: tofu apply tfplan"
