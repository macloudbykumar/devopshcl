terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.30"
    }
  }
}

provider "azurerm" {
  features {}
  client_id       = "ca1ed412"
  tenant_id       = "fde091a"
  subscription_id = "977"
}
