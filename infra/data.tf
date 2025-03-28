provider "azurerm" {
  features {
    resource_group {
       prevent_deletion_if_contains_resources = false
    }
  }
}

terraform {
  backend "azurerm" {
    resource_group_name  = "ecr-storage-rg"
    storage_account_name = "storageforme0106"
    container_name       = "terraform-state-container"
    key                  = "azure_devops_setup-ci-terraform.tfstate" # A unique key for this state file
  }
}
