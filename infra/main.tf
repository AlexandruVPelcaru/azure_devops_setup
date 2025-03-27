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
    WEBSITES_PORT = "8080"
    DB_HOST       = azurerm_mysql_flexible_server.mysql_flexible_server.fqdn
    DB_USER       = var.administrator_login
    DB_PASSWORD   = var.administrator_password
    DB_NAME       = azurerm_mysql_flexible_database.mysql_flexible_server_database.name
  }
}

