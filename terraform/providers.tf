terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.79.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.4.0"
    }
  }

  backend "azurerm" {
    key      = "terraform.tfstate"
    use_oidc = true
  }
}

provider "azurerm" {
  features {}
  use_oidc        = true
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}