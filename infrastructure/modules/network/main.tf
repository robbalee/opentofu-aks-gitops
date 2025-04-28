/**
 * # Network Module
 * 
 * Creates the virtual network and subnets for the AKS cluster
 */

resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space
  tags                = var.tags
}

resource "azurerm_subnet" "subnet" {
  for_each             = var.subnet_names
  name                 = each.value
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet_prefixes[each.key]]
}

resource "azurerm_network_security_group" "subnet_nsg" {
  for_each            = var.subnet_names
  name                = "nsg-${each.value}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg_association" {
  for_each                  = var.subnet_names
  subnet_id                 = azurerm_subnet.subnet[each.key].id
  network_security_group_id = azurerm_network_security_group.subnet_nsg[each.key].id
}
