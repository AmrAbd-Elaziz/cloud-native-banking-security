terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Intentionally vulnerable Azure infrastructure for authorized static analysis.
# Do not run terraform apply against a real Azure subscription.

resource "azurerm_resource_group" "banking" {
  name     = "rg-banking-vulnerable"
  location = var.azure_location

  tags = {
    Environment = "training-vulnerable"
    DataClass   = "financial"
  }
}

resource "azurerm_storage_account" "transaction_logs" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.banking.name
  location                 = azurerm_resource_group.banking.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  https_traffic_only_enabled          = false
  min_tls_version                     = "TLS1_0"
  public_network_access_enabled       = true
  allow_nested_items_to_be_public     = true
  shared_access_key_enabled           = true
  infrastructure_encryption_enabled   = false
  cross_tenant_replication_enabled    = true

  tags = {
    Environment = "training-vulnerable"
    DataClass   = "financial-audit"
  }
}

resource "azurerm_storage_container" "transaction_logs" {
  name                  = "transaction-logs"
  storage_account_id    = azurerm_storage_account.transaction_logs.id
  container_access_type = "blob"
}

resource "azurerm_network_security_group" "banking" {
  name                = "nsg-banking-vulnerable"
  location            = azurerm_resource_group.banking.location
  resource_group_name = azurerm_resource_group.banking.name

  security_rule {
    name                       = "Allow-Public-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-Public-SQL"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Environment = "training-vulnerable"
  }
}

resource "azurerm_key_vault" "banking" {
  name                = var.key_vault_name
  location            = azurerm_resource_group.banking.location
  resource_group_name = azurerm_resource_group.banking.name
  tenant_id           = var.tenant_id
  sku_name            = "standard"

  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  enable_rbac_authorization   = false
  public_network_access_enabled = true

  network_acls {
    bypass         = "AzureServices"
    default_action = "Allow"
  }

  tags = {
    Environment = "training-vulnerable"
    DataClass   = "secrets"
  }
}

resource "azurerm_mssql_server" "banking" {
  name                         = var.sql_server_name
  resource_group_name          = azurerm_resource_group.banking.name
  location                     = azurerm_resource_group.banking.location
  version                      = "12.0"
  administrator_login          = var.sql_administrator_login
  administrator_login_password = var.sql_administrator_password

  minimum_tls_version           = "1.0"
  public_network_access_enabled = true

  tags = {
    Environment = "training-vulnerable"
    DataClass   = "cardholder-data"
  }
}

resource "azurerm_mssql_firewall_rule" "allow_internet" {
  name             = "AllowAllInternet"
  server_id        = azurerm_mssql_server.banking.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}

resource "azurerm_mssql_database" "banking" {
  name      = "banking"
  server_id = azurerm_mssql_server.banking.id
  sku_name  = "S0"

  transparent_data_encryption_enabled = false
  zone_redundant                      = false

  tags = {
    Environment = "training-vulnerable"
    DataClass   = "cardholder-data"
  }
}

resource "azurerm_kubernetes_cluster" "banking" {
  name                = "aks-banking-vulnerable"
  location            = azurerm_resource_group.banking.location
  resource_group_name = azurerm_resource_group.banking.name
  dns_prefix          = "banking-vulnerable"

  private_cluster_enabled           = false
  role_based_access_control_enabled = false
  local_account_disabled            = false
  azure_policy_enabled              = false

  api_server_access_profile {
    authorized_ip_ranges = ["0.0.0.0/0"]
  }

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2s_v3"
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "training-vulnerable"
    DataClass   = "financial-workloads"
  }
}