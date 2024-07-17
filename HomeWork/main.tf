terraform{
    required_providers {
      azurerm = {
        source = "hashicorp/azurerm"
        version = ">=3.0"
      }
    }

    # backend "azurerm"{
    #     subscription_id = "d4ecd8ca-959f-44dd-aace-d25cec910ab5"
    #     resource_group_name = "resource_group-organize"
    #     storage_account_name = "socatastorageaccount"
    #     container_name = "terraform"
    #     key = "terraform.tfstate"
    #     use_azuread_auth = true
    # }

}

provider "azurerm" {
  subscription_id = var.subscription_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
  features {}
}
