resource "azurerm_resource_group" "rg" {
  name     = "avd-demo-rg"
  location = "eastus"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "avd-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = "eastus"
  address_space       = ["10.10.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "avd-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}
