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
  client_id       = "ca1ed475-878a-4d44-8d36-b4fff4841212"
  tenant_id       = "fde87d36-bcb0-4100-9123-38d63043091a"
  subscription_id = "9775115b-e406-42f3-b7ae-5af68ba4f9ca"
}
