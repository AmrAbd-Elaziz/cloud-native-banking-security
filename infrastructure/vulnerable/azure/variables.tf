variable "azure_location" {
  description = "Azure region used by the fictional banking environment"
  type        = string
  default     = "North Europe"
}

variable "tenant_id" {
  description = "Fictional Azure tenant identifier"
  type        = string
  default     = "00000000-0000-0000-0000-000000000000"
}

variable "storage_account_name" {
  description = "Globally unique fictional storage account name"
  type        = string
  default     = "bankinglogsvulnerable"
}

variable "key_vault_name" {
  description = "Globally unique fictional Key Vault name"
  type        = string
  default     = "kv-banking-vulnerable"
}

variable "sql_server_name" {
  description = "Globally unique fictional Azure SQL server name"
  type        = string
  default     = "sql-banking-vulnerable"
}

variable "sql_administrator_login" {
  description = "Fictional SQL administrator login"
  type        = string
  default     = "bankingadmin"
}

variable "sql_administrator_password" {
  description = "SQL administrator password supplied securely at runtime"
  type        = string
  sensitive   = true
}