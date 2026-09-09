resource "azurerm_user_assigned_identity" "storage" {
  name                = "id-banking-storage"
  location            = azurerm_resource_group.banking.location
  resource_group_name = azurerm_resource_group.banking.name

  tags = {
    Environment = var.environment
  }
}

resource "azurerm_key_vault_key" "storage" {
  name         = "banking-storage-key"
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

resource "azurerm_role_assignment" "storage_key_access" {
  scope                = azurerm_key_vault.banking.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_user_assigned_identity.storage.principal_id
}

resource "azurerm_storage_account" "transaction_logs" {
  name                = var.storage_account_name
  resource_group_name = azurerm_resource_group.banking.name
  location            = azurerm_resource_group.banking.location

  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "GRS"

  https_traffic_only_enabled        = true
  min_tls_version                   = "TLS1_2"
  public_network_access_enabled     = false
  allow_nested_items_to_be_public   = false
  shared_access_key_enabled         = false
  default_to_oauth_authentication   = true
  infrastructure_encryption_enabled = true
  cross_tenant_replication_enabled  = false

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.storage.id]
  }

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }

  blob_properties {
    versioning_enabled       = true
    change_feed_enabled      = true
    last_access_time_enabled = true

    delete_retention_policy {
      days = 365
    }

    container_delete_retention_policy {
      days = 365
    }

    restore_policy {
      days = 30
    }
  }

  queue_properties {
    logging {
      delete                = true
      read                  = true
      write                 = true
      version               = "1.0"
      retention_policy_days = 365
    }
  }

  tags = {
    Environment = var.environment
    DataClass   = "financial-audit"
  }
}

resource "azurerm_storage_account_customer_managed_key" "transaction_logs" {
  storage_account_id        = azurerm_storage_account.transaction_logs.id
  key_vault_id              = azurerm_key_vault.banking.id
  key_name                  = azurerm_key_vault_key.storage.name
  user_assigned_identity_id = azurerm_user_assigned_identity.storage.id

  depends_on = [
    azurerm_role_assignment.storage_key_access
  ]
}

resource "azurerm_storage_container" "transaction_logs" {
    # checkov:skip=CKV2_AZURE_21:Modern StorageRead diagnostic logging is enabled through azurerm_monitor_diagnostic_setting; legacy Storage Insights would require shared-key authentication.
  name                  = "transaction-logs"
  storage_account_id    = azurerm_storage_account.transaction_logs.id
  container_access_type = "private"
}

resource "azurerm_storage_management_policy" "transaction_logs" {
  storage_account_id = azurerm_storage_account.transaction_logs.id

  rule {
    name    = "financial-audit-retention"
    enabled = true

    filters {
      prefix_match = ["transaction-logs/"]
      blob_types   = ["blockBlob"]
    }

    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = 30
        tier_to_archive_after_days_since_modification_greater_than = 90
        delete_after_days_since_modification_greater_than          = 2555
      }

      snapshot {
        delete_after_days_since_creation_greater_than = 365
      }

      version {
        delete_after_days_since_creation = 2555
      }
    }
  }
}

resource "azurerm_private_endpoint" "storage_blob" {
  name                = "pe-banking-storage-blob"
  location            = azurerm_resource_group.banking.location
  resource_group_name = azurerm_resource_group.banking.name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-banking-storage-blob"
    private_connection_resource_id = azurerm_storage_account.transaction_logs.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  tags = {
    Environment = var.environment
  }
}

resource "azurerm_monitor_diagnostic_setting" "storage_blob" {
  name                       = "storage-blob-security-audit"
  target_resource_id         = "${azurerm_storage_account.transaction_logs.id}/blobServices/default"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.banking.id

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }

  metric {
    category = "Transaction"
    enabled  = true
  }
}