/**
 * # Production Environment Variables
 */

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "aksflux"
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Production"
    Project     = "AKS-GitOps"
    ManagedBy   = "OpenTofu"
  }
}
