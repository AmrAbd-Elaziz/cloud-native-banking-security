resource "azurerm_disk_encryption_set" "aks" {
  name                = "des-banking-aks"
  resource_group_name = azurerm_resource_group.banking.name
  location            = azurerm_resource_group.banking.location
  key_vault_key_id    = azurerm_key_vault_key.storage.id
  encryption_type     = "EncryptionAtRestWithCustomerKey"

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = var.environment
    DataClass   = "financial-workloads"
  }
}

resource "azurerm_role_assignment" "aks_disk_key_access" {
  scope                = azurerm_key_vault.banking.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_disk_encryption_set.aks.identity[0].principal_id
}