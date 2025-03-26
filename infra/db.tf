resource "azurerm_resource_group" "resource_group" {
  name     = "${var.app_name}-${var.env}-rg"
  location = var.location
}

resource "azurerm_mysql_flexible_server" "mysql_flexible_server" {
  name                   = "${var.app_name}-${var.env}-mysql"
  resource_group_name    = azurerm_resource_group.resource_group.name
  location               = azurerm_resource_group.resource_group.location
  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password
  sku_name               = "B_Standard_B1ms"
  delegated_subnet_id    = azurerm_subnet.subnet.id
  private_dns_zone_id    = azurerm_private_dns_zone.private_dns_zone.id

  depends_on = [azurerm_private_dns_zone_virtual_network_link.private_dns_zone_virtual_network_link]
}

resource "azurerm_mysql_flexible_database" "mysql_flexible_server_database" {
  name                = "${var.app_name}-${var.env}-database"
  resource_group_name = azurerm_resource_group.resource_group.name
  server_name         = azurerm_mysql_flexible_server.mysql_flexible_server.name
  charset             = "utf8"
  collation           = "utf8_general_ci"
}


resource "azurerm_virtual_network" "virtual_network" {
  name                = "${var.app_name}-${var.env}-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name
  address_space       = var.vnet_address_space
}

resource "azurerm_subnet" "subnet" {
  name                                          = "${var.app_name}-${var.env}-subnet"
  resource_group_name                           = azurerm_resource_group.resource_group.name
  virtual_network_name                          = azurerm_virtual_network.virtual_network.name
  address_prefixes                              = var.subnet_address_prefixes
  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_private_endpoint" "private_endpoint" {
  name                = "${var.app_name}-${var.env}-pv"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  subnet_id           = azurerm_subnet.subnet.id

  private_service_connection {
    name                           = "${var.app_name}-${var.env}-mysql-connection"
    private_connection_resource_id = azurerm_mysql_flexible_server.mysql_flexible_server.id
    is_manual_connection           = false
  }
}

resource "azurerm_private_dns_zone" "private_dns_zone" {
  name                = "${var.app_name}-${var.env}.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_zone_virtual_network_link" {
  name                  = "${var.app_name}-${var.env}-link"
  resource_group_name   = azurerm_resource_group.resource_group.name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.virtual_network.id
}

resource "azurerm_private_dns_a_record" "private_dns_a_record" {
  name                = azurerm_mysql_flexible_server.mysql_flexible_server.name
  zone_name           = azurerm_private_dns_zone.private_dns_zone.name
  resource_group_name = azurerm_resource_group.resource_group.name
  ttl                 = 300
  records             = [azurerm_mysql_flexible_server.mysql_flexible_server.fqdn]
}
