provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "ecr-storage-rg"
    storage_account_name = "storageforme0106"
    container_name       = "terraform-state-container"
    key                  = "azure_devops_setup-ci-terraform.tfstate" # A unique key for this state file
  }
}
