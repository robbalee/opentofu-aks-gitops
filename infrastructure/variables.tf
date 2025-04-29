/**
 * # Input Variables
 * 
 * Common variables used throughout the OpenTofu configurations
 */

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Networking Variables
variable "address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_prefixes" {
  description = "Address prefixes for the subnets"
  type        = map(string)
  default = {
    aks = "10.0.0.0/22"
    app = "10.0.4.0/24"
  }
}

variable "subnet_names" {
  description = "Names of the subnets"
  type        = map(string)
  default = {
    aks = "snet-aks"
    app = "snet-app"
  }
}

# AKS Variables
variable "kubernetes_version" {
  description = "Version of Kubernetes to use"
  type        = string
  default     = "1.29.0"
}

variable "default_node_pool_name" {
  description = "Name of the default node pool"
  type        = string
  default     = "system"
}

variable "default_node_pool_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 3
}

variable "default_node_pool_vm_size" {
  description = "VM size for the default node pool"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "additional_node_pools" {
  description = "Additional node pools to create"
  type = map(object({
    name       = string
    vm_size    = string
    node_count = number
    taints     = list(string)
    labels     = map(string)
  }))
  default = {}
}
