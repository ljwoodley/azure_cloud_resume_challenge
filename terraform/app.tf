resource "azurerm_application_insights" "main" {
  name                = "${var.azure_function_name}-${random_string.main.result}-appinsights"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"
}

resource "azurerm_service_plan" "main" {
  name                = "ASP-${var.azure_function_name}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "main" {
  name                       = "${var.azure_function_name}${random_string.main.result}"
  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  service_plan_id            = azurerm_service_plan.main.id
  storage_account_name       = azurerm_storage_account.appsa.name
  storage_account_access_key = azurerm_storage_account.appsa.primary_access_key


  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "WEBSITE_RUN_FROM_PACKAGE"            = 1
    "FUNCTIONS_WORKER_RUNTIME"            = "python"
    "APPINSIGHTS_INSTRUMENTATIONKEY"      = azurerm_application_insights.main.instrumentation_key
    "APPINSIGHTS_CONNECTION_STRING"       = azurerm_application_insights.main.connection_string
    "AzureWebJobsStorage"                 = azurerm_storage_account.appsa.primary_connection_string
    "AzureCosmosDBConnectionString"       = azurerm_cosmosdb_account.cosmosdb_account.connection_strings[0]
  }

  site_config {
    application_insights_key               = azurerm_application_insights.main.instrumentation_key
    application_insights_connection_string = azurerm_application_insights.main.connection_string

    application_stack {
      python_version = 3.11
    }

    cors {
      allowed_origins     = ["https://www.laurencejwoodley.com"]
    }
  }

  lifecycle {
    ignore_changes = [
      app_settings["APPINSIGHTS_INSTRUMENTATIONKEY"],
      app_settings["AzureWebJobsStorage"]
    ]
  }
}
