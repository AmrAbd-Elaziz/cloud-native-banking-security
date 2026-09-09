resource "azurerm_resource_group" "banking" {
  name     = "rg-banking-remediated"
  location = var.azure_location

  tags = {
    Environment = var.environment
    Project     = "cloud-native-banking-security"
    DataClass   = "financial"
  }
}

resource "azurerm_log_analytics_workspace" "banking" {
  name                = var.log_analytics_workspace_name
  location            = azurerm_resource_group.banking.location
  resource_group_name = azurerm_resource_group.banking.name
  sku                 = "PerGB2018"
  retention_in_days   = 365

  internet_ingestion_enabled = false
  internet_query_enabled     = false

  tags = {
    Environment = var.environment
    DataClass   = "security-audit"
  }
}