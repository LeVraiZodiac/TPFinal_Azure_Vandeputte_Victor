provider "azurerm" {
  features {}
  subscription_id = "cc39aed2-3c3a-4ee3-9b03-67b41165aba5"
}

resource "azurerm_resource_group" "rg" {
  name     = "my-final-web-app-resource"
  location = "UK South"
}

resource "azurerm_service_plan" "app_plan" {
  name                = "my-final-app-service-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type            = "Linux"
  sku_name           = "F1"
}

# Remplacement de azurerm_app_service par azurerm_linux_web_app
resource "azurerm_linux_web_app" "web_app" {
  name                = "my-final-web-app"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.app_plan.id

  site_config {
    always_on = false
    application_stack {
      node_version = "20-lts"
    }
  }

  app_settings = {
    "WEBSITE_NODE_DEFAULT_VERSION" = "20-lts"
  }
}

resource "azurerm_storage_account" "storage" {
  name                     = "myfinalstorage"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  blob_properties {
    versioning_enabled = false
    container_delete_retention_policy {
      days = 14
    }
  }
}

resource "azurerm_storage_queue" "queue" {
  name                 = "image-processing-queue"
  storage_account_name = azurerm_storage_account.storage.name
}

# resource "azurerm_container_group" "aci" {
#   name                = "my-final-image-processor"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
#   os_type            = "Linux"

#   container {
#     name   = "image-processor"
#     image  = "monregistry.azurecr.io/image-processor:latest"
#     cpu    = "0.5"
#     memory = "1.5"

#     environment_variables = {
#       "QUEUE_NAME"          = azurerm_storage_queue.queue.name
#       "STORAGE_ACCOUNT"     = azurerm_storage_account.storage.name
#       "AZURE_FUNCTION_URL"  = "https://monfunction.azurewebsites.net/api/process"
#     }
#   }

#   restart_policy = "Never"
# }

output "webapp_url" {
  value = azurerm_linux_web_app.web_app.default_hostname
}

output "web_app_name" {
  value = azurerm_linux_web_app.web_app.name
}