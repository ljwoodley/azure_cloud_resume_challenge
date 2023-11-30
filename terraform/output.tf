output "resource_group_name" {
  value     = azurerm_resource_group.main.name
  sensitive = true
}

output "cosmosdb_connection_string" {
  value     = azurerm_cosmosdb_account.cosmosdb_account.connection_strings[0]
  sensitive = true
}

output "cdn_profile_name" {
  value     = azurerm_cdn_profile.main.name
  sensitive = true
}

output "cdn_endpoint_name" {
  value     = azurerm_cdn_endpoint.main.name
  sensitive = true
}

output "function_app_name" {
  value     = azurerm_linux_function_app.main.name
  sensitive = true
}

output "function_app_url" {
  value     = azurerm_linux_function_app.main.default_hostname
  sensitive = true
}

output "static_website_storage_name" {
  value     = azurerm_storage_account.static_website.name
  sensitive = true
}
