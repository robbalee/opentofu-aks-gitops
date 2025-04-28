/**
 * # Key Vault Module Outputs
 */

output "keyvault_id" {
  description = "ID of the Azure Key Vault"
  value       = azurerm_key_vault.keyvault.id
}

output "keyvault_name" {
  description = "Name of the Azure Key Vault"
  value       = azurerm_key_vault.keyvault.name
}

output "keyvault_uri" {
  description = "URI of the Azure Key Vault"
  value       = azurerm_key_vault.keyvault.vault_uri
}
