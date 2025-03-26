variable "app_name" {
  description = "application name"
  type        = string
  default     = "azure_devops_setup"
}

variable "location" {
  description = "Location of the resources"
  type        = string
  default     = "West Europe"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_prefixes" {
  description = "Address prefixes for the subnet"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "registryforme"
}

variable "env" {
  description = "Environment"
  type        = string
  default     = "ci"
}

variable "administrator_login" {
  description = "The administrator login for the MySQL server"
  type        = string
}

variable "administrator_password" {
  description = "The administrator password for the MySQL server"
  type        = string
}
