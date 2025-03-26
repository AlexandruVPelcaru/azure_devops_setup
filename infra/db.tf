resource "azurerm_resource_group" "resource_group" {
  name     = "${var.app_name}-${var.env}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "virtual_network" {
  name                = "${var.app_name}-${var.env}-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name
  address_space       = var.vnet_address_space
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.app_name}-${var.env}-subnet"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = var.subnet_address_prefixes
  private_link_service_network_policies_enabled  = true
}

resource "azurerm_cosmosdb_account" "cosmosdb_account" {
  name                = "${var.app_name}-${var.env}-db"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"
  free_tier_enabled    = true

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.resource_group.location
    failover_priority = 0
  }
}

resource "azurerm_private_endpoint" "private_endpoint" {
  name                = "${var.app_name}-${var.env}-pv"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  subnet_id           = azurerm_subnet.subnet.id

  private_service_connection {
    name                           = "${var.app_name}-${var.env}-psc"
    private_connection_resource_id = azurerm_cosmosdb_account.cosmosdb_account.id
    is_manual_connection           = false
    subresource_names              = ["sql"]
  }
}

resource "azurerm_private_dns_zone" "private_dns_zone" {
  name                = "${var.app_name}-${var.env}-pdz"
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_zone_virtual_network_link" {
  name                  = "${var.app_name}-${var.env}-link"
  resource_group_name   = azurerm_resource_group.resource_group.name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.virtual_network.id
}

resource "azurerm_private_dns_a_record" "private_dns_a_record" {
  name                = azurerm_cosmosdb_account.cosmosdb_account.name
  zone_name           = azurerm_private_dns_zone.private_dns_zone.name
  resource_group_name = azurerm_resource_group.resource_group.name
  ttl                 = 300
  records             = [azurerm_cosmosdb_account.example.endpoint]
}

resource "azurerm_cosmosdb_sql_database" "sql_database" {
  name                = "${var.app_name}-${var.env}-db"
  account_name        = azurerm_cosmosdb_account.cosmosdb_account.name
  resource_group_name = azurerm_resource_group.resource_group.name
  throughput          = 400
}

resource "azurerm_cosmosdb_sql_container" "sql_container" {
  name                = "${var.app_name}-${var.env}-db-container"
  resource_group_name = azurerm_resource_group.resource_group.name
  account_name        = azurerm_cosmosdb_account.cosmosdb_account.name
  database_name       = azurerm_cosmosdb_sql_database.sql_database.name
  partition_key_paths = ["/partitionKey"]
  throughput          = 400

  indexing_policy {
    indexing_mode = "consistent"
    included_path {
      path = "/*"
    }
    excluded_path {
      path = "/excluded/?"
    }
  }

  unique_key {
    paths = ["/uniqueKey"]
  }
}
