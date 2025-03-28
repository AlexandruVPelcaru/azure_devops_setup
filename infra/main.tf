resource "azurerm_service_plan" "app_service_plan" {
  name                = "${var.app_name}-${var.env}-plan"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "app_service" {
  name                = "${var.app_name}-${var.env}-app"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  service_plan_id     = azurerm_service_plan.app_service_plan.id

  site_config {
    always_on = false
    application_stack {
      docker_image_name   = "${var.app_name}-${var.env}-app:latest"
      docker_registry_url = var.ecr_repository_name
      docker_registry_username = var.docker_registry_username
      docker_registry_password = var.docker_registry_password
    }
  }

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    WEBSITES_PORT = 8080
  }
}

