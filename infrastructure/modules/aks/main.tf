/**
 * # AKS Module
 * 
 * Creates an Azure Kubernetes Service cluster
 */

resource "azurerm_user_assigned_identity" "aks" {
  name                = "id-aks-${var.cluster_name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.cluster_name
  kubernetes_version  = var.kubernetes_version
  tags                = var.tags

  default_node_pool {
    name                = var.default_node_pool_name
    node_count          = var.default_node_pool_count
    vm_size             = var.default_node_pool_vm_size
    vnet_subnet_id      = var.vnet_subnet_id
    enable_auto_scaling = true
    min_count           = var.default_node_pool_count
    max_count           = var.default_node_pool_count * 2
    os_disk_size_gb     = 100
  }

  network_profile {
    network_plugin     = "azure"
    network_policy     = "azure"
    load_balancer_sku  = "standard"
    service_cidr       = "10.1.0.0/16"
    dns_service_ip     = "10.1.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  azure_active_directory_role_based_access_control {
    managed                = true
    admin_group_object_ids = var.admin_group_object_ids
  }

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count
    ]
  }
}

# Create additional node pools if specified
resource "azurerm_kubernetes_cluster_node_pool" "additional" {
  for_each              = var.additional_node_pools
  name                  = each.value.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = each.value.vm_size
  node_count            = each.value.node_count
  vnet_subnet_id        = var.vnet_subnet_id
  enable_auto_scaling   = true
  min_count             = each.value.node_count
  max_count             = each.value.node_count * 2
  os_disk_size_gb       = 100
  node_taints           = each.value.taints
  node_labels           = each.value.labels

  lifecycle {
    ignore_changes = [
      node_count
    ]
  }
}
