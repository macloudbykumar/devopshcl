# ----------------------------
# Resource Group
# ----------------------------
resource "azurerm_resource_group" "rg_by_kumar" {
  name     = "rg-by-kumar"
  location = "East US"
}

# ----------------------------
# Shared Image Gallery
# ----------------------------
resource "azurerm_shared_image_gallery" "sig" {
  name                = "example_image_gallery"
  resource_group_name = azurerm_resource_group.rg_by_kumar.name
  location            = azurerm_resource_group.rg_by_kumar.location
  description         = "Shared images and things"

  tags = {
    Hello = "There"
    World = "Example"
  }
}

# ----------------------------
# Shared Image (Definition)
# ----------------------------
resource "azurerm_shared_image" "image" {
  name                = "my-image"
  gallery_name        = azurerm_shared_image_gallery.sig.name
  resource_group_name = azurerm_resource_group.rg_by_kumar.name
  location            = azurerm_resource_group.rg_by_kumar.location
  os_type             = "Windows"

  hyper_v_generation = "V2"

  identifier {
    publisher = "hcl"
    offer     = "windows11"
    sku       = "1.0.0"
  }
}

data "azurerm_image" "existing" {
  name                = "avd-image-1.0.0"
  resource_group_name = "avd-demo-rg"
}

# ----------------------------
# Shared Image Version
# ----------------------------
resource "azurerm_shared_image_version" "image_version" {
  name                = "1.1.1"
  gallery_name        = azurerm_shared_image_gallery.sig.name
  image_name          = azurerm_shared_image.image.name
  resource_group_name = azurerm_resource_group.rg_by_kumar.name
  location            = azurerm_resource_group.rg_by_kumar.location

  #managed_image_id = data.azurerm_virtual_machine.vm.id
  
  managed_image_id = data.azurerm_image.existing.id  

  target_region {
    name                   = azurerm_shared_image.image.location
    regional_replica_count = 2
    storage_account_type   = "Standard_LRS"
  }
}

# ----------------------------
# Output
# ----------------------------
output "gallery_name" {
  value = azurerm_shared_image_gallery.sig.name
}