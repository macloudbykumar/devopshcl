# ----------------------------
# Resource Group
# ----------------------------
resource "azurerm_resource_group" "rg_by_kumar" {
  name     = "rg-by-kumar11"
  location = "East US"
}

resource "azurerm_virtual_desktop_host_pool" "avd_hostpool" {
  name                = "avd-hostpool-kumar"
  location            = azurerm_resource_group.rg_by_kumar.location
  resource_group_name = azurerm_resource_group.rg_by_kumar.name

  type                     = "Pooled"
  load_balancer_type       = "DepthFirst"
  maximum_sessions_allowed = 10

  preferred_app_group_type = "Desktop"

  start_vm_on_connect = true
}


resource "azurerm_virtual_desktop_host_pool_registration_info" "registration" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.avd_hostpool.id
  expiration_date = timeadd(timestamp(), "48h")
}

resource "azurerm_virtual_desktop_application_group" "desktop_appgroup" {
  name                = "avd-desktop-appgroup"
  location            = azurerm_resource_group.rg_by_kumar.location
  resource_group_name = azurerm_resource_group.rg_by_kumar.name

  type         = "Desktop"
  host_pool_id = azurerm_virtual_desktop_host_pool.avd_hostpool.id
}

resource "azurerm_virtual_desktop_workspace" "workspace" {
  name                = "avd-workspace-kumar"
  location            = azurerm_resource_group.rg_by_kumar.location
  resource_group_name = azurerm_resource_group.rg_by_kumar.name
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "assoc" {
  workspace_id         = azurerm_virtual_desktop_workspace.workspace.id
  application_group_id = azurerm_virtual_desktop_application_group.desktop_appgroup.id
}


resource "azurerm_virtual_network" "vnet" {
  name                = "avd-vnet"
  location            = azurerm_resource_group.rg_by_kumar.location
  resource_group_name = azurerm_resource_group.rg_by_kumar.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "avd-subnet"
  resource_group_name  = azurerm_resource_group.rg_by_kumar.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "nic" {
  count               = 1
  name                = "avd-nic-${count.index}"
  location            = azurerm_resource_group.rg_by_kumar.location
  resource_group_name = azurerm_resource_group.rg_by_kumar.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "session_host" {
  count               = 1
  name                = "avd-vm-${count.index}"
  location            = azurerm_resource_group.rg_by_kumar.location
  resource_group_name = azurerm_resource_group.rg_by_kumar.name
  size                = "Standard_B2s"

  admin_username = "azureuser"
  admin_password = "P@ssword1234!"  # Use Key Vault in real setup

  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id
  ]

  #source_image_id = azurerm_shared_image_version.image_version.id
  source_image_id = "/subscriptions/9775115b-e406-42f3-b7ae-5af68ba4f9ca/resourceGroups/rg-by-kumar/providers/Microsoft.Compute/galleries/example_image_gallery/images/my-image/versions/1.1.1"
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }
}

resource "azurerm_virtual_machine_extension" "avd_agent" {
  count                = 1
  name                 = "avd-agent-${count.index}"
  virtual_machine_id   = azurerm_windows_virtual_machine.session_host[count.index].id
  publisher            = "Microsoft.Powershell"
  type                 = "DSC"
  type_handler_version = "2.73"

  settings = jsonencode({
    modulesUrl = "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration.zip"
    configurationFunction = "Configuration.ps1\\AddSessionHost"
    properties = {
      hostPoolName = azurerm_virtual_desktop_host_pool.avd_hostpool.name
      registrationInfoToken = azurerm_virtual_desktop_host_pool_registration_info.registration.token
    }
  })
}


output "hostpool_name" {
  value = azurerm_virtual_desktop_host_pool.avd_hostpool.name
}

output "workspace_url" {
  value = azurerm_virtual_desktop_workspace.workspace.id
}