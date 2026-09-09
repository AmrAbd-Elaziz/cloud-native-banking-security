resource "azurerm_key_vault" "banking" {
  name                = var.key_vault_name
  location            = azurerm_resource_group.banking.location
  resource_group_name = azurerm_resource_group.banking.name
  tenant_id           = var.tenant_id
  sku_name            = "premium"

  soft_delete_retention_days    = 90
  purge_protection_enabled      = true
  enable_rbac_authorization     = true
  public_network_access_enabled = false
  enabled_for_disk_encryption   = true

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
  }

  tags = {
    Environment = var.environment
    DataClass   = "cryptographic-material"
  }
}

resource "azurerm_role_assignment" "key_vault_security_admin" {
  scope                = azurerm_key_vault.banking.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = var.security_admin_object_id
}

resource "azurerm_private_endpoint" "key_vault" {
  name                = "pe-banking-key-vault"
  location            = azurerm_resource_group.banking.location
  resource_group_name = azurerm_resource_group.banking.name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-banking-key-vault"
    private_connection_resource_id = azurerm_key_vault.banking.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  tags = {
    Environment = var.environment
  }
}

resource "azurerm_monitor_diagnostic_setting" "key_vault" {
  name                       = "key-vault-security-audit"
  target_resource_id         = azurerm_key_vault.banking.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.banking.id

  enabled_log {
    category = "AuditEvent"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}