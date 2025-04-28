/**
 * # Network Module Outputs
 */

output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "subnet_ids" {
  description = "IDs of the created subnets"
  value       = { for k, v in azurerm_subnet.subnet : k => v.id }
}

output "subnet_names" {
  description = "Names of the created subnets"
  value       = { for k, v in azurerm_subnet.subnet : k => v.name }
}
