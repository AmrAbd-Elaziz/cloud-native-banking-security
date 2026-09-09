variable "azure_location" {
  description = "Primary Azure region"
  type        = string
  default     = "North Europe"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "training-remediated"
}

variable "tenant_id" {
  description = "Azure tenant identifier"
  type        = string
  default     = "00000000-0000-0000-0000-000000000000"
}

variable "security_admin_object_id" {
  description = "Object ID of the approved security administrator"
  type        = string
  default     = "00000000-0000-0000-0000-000000000001"
}

variable "storage_account_name" {
  description = "Globally unique secured storage account name"
  type        = string
  default     = "bankinglogsremediated"
}

variable "key_vault_name" {
  description = "Globally unique secured Key Vault name"
  type        = string
  default     = "kv-banking-remediated"
}

variable "sql_server_name" {
  description = "Globally unique secured Azure SQL server name"
  type        = string
  default     = "sql-banking-remediated"
}

variable "private_endpoint_subnet_id" {
  description = "Existing dedicated subnet for private endpoints"
  type        = string
  default     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-banking/subnets/private-endpoints"
}

variable "aks_subnet_id" {
  description = "Existing private subnet used by AKS"
  type        = string
  default     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-banking/subnets/aks"
}

variable "aks_admin_group_object_ids" {
  description = "Approved Microsoft Entra ID groups administering AKS"
  type        = list(string)

  default = [
    "00000000-0000-0000-0000-000000000002"
  ]
}

variable "log_analytics_workspace_name" {
  description = "Central banking security monitoring workspace"
  type        = string
  default     = "log-banking-security"
}
variable "security_alert_email_addresses" {
  description = "Approved security operations alert recipients"
  type        = list(string)

  default = [
    "security-operations@example.com"
  ]
}