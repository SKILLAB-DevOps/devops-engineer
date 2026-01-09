provider "azurerm" {
  features {}
}

locals {
    resource_group_name = "rg-robot-dreams-deploy"
    location            = "West Europe"
    storage_account_name = "storrobotdreamsdeploy"
    app_service_plan_name = "splan-robot-dreams-deploy"
    function_app_name = "func-robot-dreams-deploy"
}

resource "azurerm_resource_group" "robot_dreams" {
  name     = local.resource_group_name
  location = local.location
}

resource "azurerm_storage_account" "robot_dreams" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.robot_dreams.name
  location                 = azurerm_resource_group.robot_dreams.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "robot_dreams" {
  name                = local.app_service_plan_name
  resource_group_name = azurerm_resource_group.robot_dreams.name
  location            = azurerm_resource_group.robot_dreams.location
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_function_app" "robot_dreams" {
  name                = local.function_app_name
  resource_group_name = azurerm_resource_group.robot_dreams.name
  location            = azurerm_resource_group.robot_dreams.location

  storage_account_name       = azurerm_storage_account.robot_dreams.name
  storage_account_access_key = azurerm_storage_account.robot_dreams.primary_access_key
  service_plan_id            = azurerm_service_plan.robot_dreams.id

  site_config {
    always_on = true
    application_stack {
      python_version = "3.10"
    }
  }
}

output "function_app_url" {
  value = "https://${azurerm_linux_function_app.robot_dreams.default_hostname}/"
}