variable "rg_name" {
  type = string
}

variable "rg_location" {
  type = string
}

variable "cosmosdb_account_name" {
  type = string
}

variable "cosmosdb_sql_database_name" {
  type = string
}

variable "cosmosdb_sql_container_name" {
  type = string
}

variable "azure_function_name" {
  type = string
}

variable "static_website_storage_account" {
  type = string
}

variable "cdn_profile_name" {
  type = string
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "Tenant ID for Azure"
  type        = string
}

