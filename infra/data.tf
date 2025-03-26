provider "azurerm" {
  features {}
  subscription_id = var.subscriptionId
}

terraform {
  backend "azurerm" {
    resource_group_name  = "ecr-storage-rg"
    storage_account_name = "storageforme0106"
    container_name       = "terraform-state-container"
    key                  = "${var.app_name}-${var.env}-terraform.tfstate" # A unique key for this state file
  }
}
