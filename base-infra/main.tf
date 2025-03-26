resource "azurerm_resource_group" "resource_group" {
  name     = "ecr-storage-rg"
  location = "West Europe"
}

resource "azurerm_storage_account" "storage_account" {
  name                     = "storageforme0106"
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = azurerm_resource_group.resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "storage_container" {
  name                  = "terraform-state-container"
  storage_account_id    = azurerm_storage_account.storage_account.id
  container_access_type = "private"
}

resource "azurerm_container_registry" "container_registry" {
  name                = "registryforme"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  sku                 = "Basic"

  admin_enabled = true
}
