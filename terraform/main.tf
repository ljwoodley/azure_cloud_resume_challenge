resource "azurerm_resource_group" "main" {
  name     = var.rg_name
  location = var.rg_location
}

resource "random_string" "main" {
  length  = 8
  special = false
  upper   = false
}

