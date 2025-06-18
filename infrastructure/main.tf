/**
 * # Main OpenTofu Configuration
 * 
 * Root module that invokes all other modules to provision the complete AKS infrastructure.
 */

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    # Backend configuration will be specified in a separate .tfvars file or via CLI
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
  }
}

# Local variables for common configuration
locals {
  environment         = var.environment
  location            = var.location
  resource_group_name = "rg-${var.project_name}-${local.environment}"
  tags = merge(var.tags, {
    Environment = local.environment
    ManagedBy   = "OpenTofu"
    Project     = var.project_name
  })
}

# Create Resource Group
resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = local.location
  tags     = local.tags
}

# Network Module
module "network" {
  source              = "./modules/network"
  resource_group_name = azurerm_resource_group.main.name
  location            = local.location
  environment         = local.environment
  address_space       = var.address_space
  subnet_prefixes     = var.subnet_prefixes
  subnet_names        = var.subnet_names
  tags                = local.tags
}

# AKS Module
module "aks" {
  source                    = "./modules/aks"
  resource_group_name       = azurerm_resource_group.main.name
  location                  = local.location
  environment               = local.environment
  cluster_name              = "aks-${var.project_name}-${local.environment}"
  kubernetes_version        = var.kubernetes_version
  vnet_subnet_id            = module.network.subnet_ids["aks"]
  default_node_pool_name    = var.default_node_pool_name
  default_node_pool_count   = var.default_node_pool_count
  default_node_pool_vm_size = var.default_node_pool_vm_size
  additional_node_pools     = var.additional_node_pools
  tags                      = local.tags

  depends_on = [
    module.network
  ]
}

# Azure Container Registry Module
module "acr" {
  source              = "./modules/acr"
  resource_group_name = azurerm_resource_group.main.name
  location            = local.location
  environment         = local.environment
  acr_name            = "acr${var.project_name}${local.environment}"
  sku                 = "Standard"
  tags                = local.tags
}

# Key Vault Module
module "keyvault" {
  source              = "./modules/keyvault"
  resource_group_name = azurerm_resource_group.main.name
  location            = local.location
  environment         = local.environment
  keyvault_name       = "kv-${var.project_name}-${local.environment}"
  tags                = local.tags
}
