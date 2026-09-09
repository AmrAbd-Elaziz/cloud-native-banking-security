resource "azurerm_kubernetes_cluster" "banking" {
  name                = "aks-banking-remediated"
  location            = azurerm_resource_group.banking.location
  resource_group_name = azurerm_resource_group.banking.name
  dns_prefix          = "banking-remediated"

  sku_tier = "Standard"
  disk_encryption_set_id = azurerm_disk_encryption_set.aks.id

  private_cluster_enabled = true
  private_dns_zone_id     = "System"

  role_based_access_control_enabled = true
  local_account_disabled            = true
  azure_policy_enabled              = true

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  automatic_upgrade_channel = "stable"
  node_os_upgrade_channel   = "SecurityPatch"

  image_cleaner_enabled        = true
  image_cleaner_interval_hours = 48
  run_command_enabled          = false

  default_node_pool {
    name                        = "system"
    node_count                  = 3
    vm_size                     = "Standard_D4s_v5"
    vnet_subnet_id              = var.aks_subnet_id
    type                        = "VirtualMachineScaleSets"
    zones                       = ["1", "2", "3"]
    only_critical_addons_enabled = true

        os_disk_type    = "Ephemeral"
    os_disk_size_gb = 128
    max_pods        = 50

    host_encryption_enabled = true
    fips_enabled            = true

    upgrade_settings {
      max_surge = "33%"
    }
  }

  network_profile {
    network_plugin      = "azure"
    network_policy      = "azure"
    network_data_plane  = "azure"
    load_balancer_sku   = "standard"
    outbound_type       = "userDefinedRouting"
  }

  azure_active_directory_role_based_access_control {
    tenant_id              = var.tenant_id
    admin_group_object_ids = var.aks_admin_group_object_ids
    azure_rbac_enabled     = true
  }

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  oms_agent {
    log_analytics_workspace_id      = azurerm_log_analytics_workspace.banking.id
    msi_auth_for_monitoring_enabled = true
  }

  microsoft_defender {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.banking.id
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = var.environment
    DataClass   = "financial-workloads"
  }
}

resource "azurerm_monitor_diagnostic_setting" "aks" {
  name                       = "aks-control-plane-security-audit"
  target_resource_id         = azurerm_kubernetes_cluster.banking.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.banking.id

  enabled_log {
    category = "kube-apiserver"
  }

  enabled_log {
    category = "kube-audit"
  }

  enabled_log {
    category = "kube-audit-admin"
  }

  enabled_log {
    category = "kube-controller-manager"
  }

  enabled_log {
    category = "kube-scheduler"
  }

  enabled_log {
    category = "cluster-autoscaler"
  }

  enabled_log {
    category = "guard"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}