variable "azurerm_container_registry_name" {
  description = "The name of the Azure Container Registry"
  type        = string
  default     = "my-registry"
}

variable "subscriptionId" {
    description = "The Azure subscription ID"
    type        = string
}