terraform{
    required_providers {
      azurerm = {
        source = "hashicorp/azurerm"
        version = ">=3.0"
      }
    }

    # backend "azurerm"{
    #     subscription_id = ""
    #     resource_group_name = "rf-terraform"
    #     storage_account_name = "terrafromstateproj"
    #     container_name = "terraform"
    #     key = "terraform.tfstate"
    #     use_azuread_auth = true
    # }

}

provider "azurerm" {
  subscription_id = "d4ecd8ca-959f-44dd-aace-d25cec910ab5"
  features {}
}
