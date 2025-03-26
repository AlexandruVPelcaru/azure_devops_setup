resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "${var.app_name}-${var.env}-plan"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  sku {
    tier = "Free"
    size = "F1"
  }
}

resource "azurerm_app_service" "app_service" {
  name                = "${var.app_name}-${var.env}-app"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id

  site_config {
    linux_fx_version = "DOCKER|${var.ecr_repository_name}.azurecr.io/${var.app_name}-${var.env}-app:latest"
  }

  app_settings = {
    WEBSITES_PORT       = "8080"                                 
    COSMOS_DB_ENDPOINT  = azurerm_cosmosdb_account.cosmosdb_account.endpoint
    COSMOS_DB_KEY       = azurerm_cosmosdb_account.cosmosdb_account.primary_key
    COSMOS_DB_NAME      = azurerm_cosmosdb_sql_database.sql_database.name          
  }
}

