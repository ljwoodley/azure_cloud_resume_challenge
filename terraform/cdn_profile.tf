resource "azurerm_cdn_profile" "main" {
  name                = var.cdn_profile_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard_Microsoft"
}

resource "azurerm_cdn_endpoint" "main" {
  name                = "${var.cdn_profile_name}${random_string.main.result}"
  profile_name        = azurerm_cdn_profile.main.name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  origin {
    name      = "saorigin"
    host_name = trimsuffix(trimprefix(azurerm_storage_account.static_website.primary_web_endpoint, "https://"), "/")
  }

  origin_host_header = trimsuffix(trimprefix(azurerm_storage_account.static_website.primary_web_endpoint, "https://"), "/")
}
