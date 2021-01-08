terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.41.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "test-kv-rg"
    storage_account_name = "teststacc01"
    container_name       = "tfstate"
    key                  = "backend-test.tfstate"
  }
}
