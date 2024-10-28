terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  required_version = ">= 1.1.0" # Set this to require a minimum Terraform version
}

provider "azurerm" {
  features {}
}

variable "resource_group_names" {
  description = "value of the resource group names"
  type = list(string)
}

variable "location" {
  description = "value of the location"
  type = string 
}

variable "account_tier" {
  description = "value of the account tier"
  type = string 
}

variable "account_replication_type" {
  description = "value of the account replication type"
  type = string
}

resource "random_string" "example" {
  length  = 4
  special = false
}

resource "azurerm_resource_group" "example" {
  count    = length(var.resource_group_names)
  name     = "${var.resource_group_names[count.index]}-${random_string.example.result}"
  location = var.location
}

resource "azurerm_storage_account" "example" {
  count                    = length(var.resource_group_names)
  name                     = lower("${var.resource_group_names[count.index]}${random_string.example.result}")
  resource_group_name      = azurerm_resource_group.example[count.index].name
  location                 = azurerm_resource_group.example[count.index].location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
} 

module "storage-account" {
  for_each = toset(var.resource_group_names)
  source              = "github.com/eelco-de-boer/terraform-azure-storage-account"
    location            = var.location
    name                = "supermodulesta"
    resource_group_name = "${each.key}-${random_string.example.result}"
}
moved {
  from = module.storage-account.azurerm_storage_account.example
  to   = module.storage-account["myTFResourceGroup"].azurerm_storage_account.example
}