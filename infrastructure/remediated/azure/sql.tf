resource "azurerm_key_vault_key" "sql" {
  name         = "banking-sql-key"
  key_vault_id = azurerm_key_vault.banking.id
  key_type     = "RSA-HSM"
  key_size     = 4096
  expiration_date = "2028-09-09T00:00:00Z"

  key_opts = [
    "decrypt",
    "encrypt",
    "unwrapKey",
    "wrapKey"
  ]

  rotation_policy {
    automatic {
      time_after_creation = "P90D"
    }

    expire_after         = "P2Y"
    notify_before_expiry = "P30D"
  }

  depends_on = [
    azurerm_role_assignment.key_vault_security_admin
  ]
}

resource "azurerm_mssql_server" "banking" {
  name                = var.sql_server_name
  resource_group_name = azurerm_resource_group.banking.name
  location            = azurerm_resource_group.banking.location
  version             = "12.0"

  minimum_tls_version                  = "1.2"
  public_network_access_enabled        = false
  outbound_network_restriction_enabled = true

  identity {
    type = "SystemAssigned"
  }

  azuread_administrator {
    login_username              = "Banking-SQL-Security-Administrators"
    object_id                   = var.security_admin_object_id
    tenant_id                   = var.tenant_id
    azuread_authentication_only = true
  }

  tags = {
    Environment = var.environment
    DataClass   = "cardholder-data"
  }
}

resource "azurerm_role_assignment" "sql_key_access" {
  scope                = azurerm_key_vault.banking.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_mssql_server.banking.identity[0].principal_id
}

resource "azurerm_mssql_server_transparent_data_encryption" "banking" {
  server_id        = azurerm_mssql_server.banking.id
  key_vault_key_id = azurerm_key_vault_key.sql.id

  auto_rotation_enabled = true

  depends_on = [
    azurerm_role_assignment.sql_key_access
  ]
}

resource "azurerm_mssql_database" "banking" {
  name      = "banking"
  server_id = azurerm_mssql_server.banking.id
  sku_name  = "BC_Gen5_2"

  transparent_data_encryption_enabled = true
  zone_redundant                      = true
  ledger_enabled                      = true

  short_term_retention_policy {
    retention_days           = 35
    backup_interval_in_hours = 12
  }

  long_term_retention_policy {
    weekly_retention  = "P12W"
    monthly_retention = "P12M"
    yearly_retention  = "P7Y"
    week_of_year      = 1
  }

  threat_detection_policy {
    state                      = "Enabled"
    email_account_admins       = "Enabled"
    retention_days             = 365
    disabled_alerts            = []
    email_addresses            = var.security_alert_email_addresses
  }

  tags = {
    Environment = var.environment
    DataClass   = "cardholder-data"
  }
}

resource "azurerm_mssql_server_extended_auditing_policy" "banking" {
  server_id              = azurerm_mssql_server.banking.id
  log_monitoring_enabled = true
  retention_in_days      = 365
}

resource "azurerm_mssql_server_security_alert_policy" "banking" {
  resource_group_name = azurerm_resource_group.banking.name
  server_name         = azurerm_mssql_server.banking.name
  state               = "Enabled"

  email_account_admins = true
  email_addresses      = var.security_alert_email_addresses
  retention_days       = 365
}

resource "azurerm_private_endpoint" "sql" {
  name                = "pe-banking-sql"
  location            = azurerm_resource_group.banking.location
  resource_group_name = azurerm_resource_group.banking.name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-banking-sql"
    private_connection_resource_id = azurerm_mssql_server.banking.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  tags = {
    Environment = var.environment
  }
}

resource "azurerm_monitor_diagnostic_setting" "sql" {
  name                       = "sql-security-audit"
  target_resource_id         = azurerm_mssql_database.banking.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.banking.id

  enabled_log {
    category = "SQLSecurityAuditEvents"
  }

  enabled_log {
    category = "Errors"
  }

  enabled_log {
    category = "Deadlocks"
  }

  enabled_log {
    category = "Blocks"
  }

  metric {
    category = "Basic"
    enabled  = true
  }
}