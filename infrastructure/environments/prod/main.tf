/**
 * # Production Environment Configuration
 * 
 * Configuration for the production environment
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
  environment = "prod"
}

module "aks_infrastructure" {
  source = "../../"

  # General configuration
  project_name = var.project_name
  environment  = local.environment
  location     = var.location
  tags         = var.tags

  # Network configuration
  address_space = ["10.1.0.0/16"]
  subnet_prefixes = {
    aks = "10.1.0.0/22"
    app = "10.1.4.0/24"
  }
  subnet_names = {
    aks = "snet-aks"
    app = "snet-app"
  }

  # AKS configuration
  kubernetes_version        = "1.29.0"
  default_node_pool_name    = "system"
  default_node_pool_count   = 3
  default_node_pool_vm_size = "Standard_D4s_v3"

  # Additional node pools for production
  additional_node_pools = {
    user = {
      name       = "user"
      vm_size    = "Standard_D4s_v3"
      node_count = 3
      taints     = []
      labels     = { "purpose" = "user" }
    }
    monitoring = {
      name       = "monitor"
      vm_size    = "Standard_D2s_v3"
      node_count = 2
      taints     = ["purpose=monitoring:NoSchedule"]
      labels     = { "purpose" = "monitoring" }
    }
  }
}
