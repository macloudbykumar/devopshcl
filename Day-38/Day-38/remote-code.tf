resource "azurerm_virtual_desktop_application_group" "remote_appgroup" {
  name                = "avd-remoteapp-group"
  location            = azurerm_resource_group.rg_by_kumar.location
  resource_group_name = azurerm_resource_group.rg_by_kumar.name
 
  type         = "RemoteApp"
  host_pool_id = azurerm_virtual_desktop_host_pool.avd_hostpool.id
}
 
 
resource "azurerm_virtual_desktop_application" "notepad" {
  name                         = "notepad-app"
  application_group_id         = azurerm_virtual_desktop_application_group.remote_appgroup.id
  friendly_name                = "Notepad"
  path                         = "C:\\Windows\\System32\\notepad.exe"
  command_line_argument_policy = "DoNotAllow"
  show_in_portal               = true
  icon_path                    = "C:\\Windows\\System32\\notepad.exe"
  icon_index                   = 0
}
 
resource "azurerm_virtual_desktop_application" "calculator" {
  name                         = "calculator-app"
  application_group_id         = azurerm_virtual_desktop_application_group.remote_appgroup.id
  friendly_name                = "Calculator"
  path                         = "C:\\Windows\\System32\\calc.exe"
  command_line_argument_policy = "DoNotAllow"
  show_in_portal               = true
  icon_path                    = "C:\\Windows\\System32\\calc.exe"
  icon_index                   = 0
}
 
 
resource "azurerm_virtual_desktop_workspace_application_group_association" "remote_assoc" {
  workspace_id         = azurerm_virtual_desktop_workspace.workspace.id
  application_group_id = azurerm_virtual_desktop_application_group.remote_appgroup.id
}
 
 
resource "azurerm_role_assignment" "avd_users" {
  scope                = azurerm_virtual_desktop_application_group.remote_appgroup.id
  role_definition_name = "Desktop Virtualization User"
 
  principal_id = "6709822d-c565-40b3-8b0a-a8519d2341a2"  # Replace with AAD group
}
 
resource "azurerm_role_assignment" "desktop_users" {
  scope                = azurerm_virtual_desktop_application_group.desktop_appgroup.id
  role_definition_name = "Desktop Virtualization User"
 
  principal_id = "6709822d-c565-40b3-8b0a-a8519d2341a2"
}