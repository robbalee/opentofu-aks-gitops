/**
 * # Staging Environment Configuration
 * 
 * Configuration for the staging environment
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
    # Will be populated from backend-config or ENV variables
  }
}

provider "azurerm" {
  features {}
}

locals {
  environment = "staging"
}

module "aks_infrastructure" {
  source = "../../"
  
  # General configuration
  project_name = var.project_name
  environment  = local.environment
  location     = var.location
  tags         = var.tags
  
  # Network configuration
  address_space   = ["10.2.0.0/16"]
  subnet_prefixes = {
    aks = "10.2.0.0/22"
    app = "10.2.4.0/24"
  }
  subnet_names    = {
    aks = "snet-aks"
    app = "snet-app"
  }
  
  # AKS configuration
  kubernetes_version        = "1.29.0"
  default_node_pool_name    = "system"
  default_node_pool_count   = 2
  default_node_pool_vm_size = "Standard_D2s_v3"
  
  # Additional node pools for staging
  additional_node_pools = {
    user = {
      name       = "user"
      vm_size    = "Standard_D2s_v3"
      node_count = 2
      taints     = []
      labels     = { "purpose" = "user" }
    }
  }
}
