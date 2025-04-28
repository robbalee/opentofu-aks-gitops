/**
 * # Output Values
 * 
 * Outputs from the OpenTofu resources to be used elsewhere
 */

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "vnet_id" {
  description = "ID of the virtual network"
  value       = module.network.vnet_id
}

output "subnet_ids" {
  description = "IDs of the created subnets"
  value       = module.network.subnet_ids
}

output "aks_cluster_id" {
  description = "ID of the AKS cluster"
  value       = module.aks.cluster_id
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = module.aks.cluster_name
}

output "kubeconfig" {
  description = "kubeconfig file content to connect to the AKS cluster"
  value       = module.aks.kubeconfig
  sensitive   = true
}

output "acr_id" {
  description = "ID of the Azure Container Registry"
  value       = module.acr.acr_id
}

output "acr_login_server" {
  description = "Login server URL for the Azure Container Registry"
  value       = module.acr.acr_login_server
}

output "keyvault_id" {
  description = "ID of the Azure Key Vault"
  value       = module.keyvault.keyvault_id
}

output "keyvault_uri" {
  description = "URI of the Azure Key Vault"
  value       = module.keyvault.keyvault_uri
}
