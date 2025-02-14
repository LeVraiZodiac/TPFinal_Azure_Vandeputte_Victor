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
  os_type             = "Linux"
  sku_name            = "F1"
}

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

resource "azurerm_app_service_source_control" "source_control" {
  app_id   = azurerm_linux_web_app.web_app.id
  repo_url = "https://github.com/LeVraiZodiac/TPFinal_Azure_Vandeputte_Victor"
  branch   = "main"
  github_action_configuration {
    generate_workflow_file = true
    code_configuration {
      runtime_stack   = "node"
      runtime_version = "20.x"
    }
  }
}

resource "azurerm_linux_web_app" "web_app_2" {
  name                = "my-final-web-app-2"
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

resource "azurerm_app_service_source_control" "source_control_2" {
  app_id   = azurerm_linux_web_app.web_app_2.id
  repo_url = "https://github.com/LeVraiZodiac/TPFinal_Azure_Vandeputte_Victor"
  branch   = "main"
  github_action_configuration {
    generate_workflow_file = true
    code_configuration {
      runtime_stack   = "node"
      runtime_version = "20.x"
    }
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "my-final-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "frontend" {
  name                 = "frontend"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name                = "my-final-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "app_gateway" {
  name                = "my-final-appgateway"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = azurerm_subnet.frontend.id
  }

  frontend_port {
    name = "frontend-port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontend-ip-config"
    public_ip_address_id = azurerm_public_ip.pip.id
  }

  backend_address_pool {
    name = "backend-pool"
    fqdns = [
      azurerm_linux_web_app.web_app.default_hostname,
      azurerm_linux_web_app.web_app_2.default_hostname
    ]
  }

  backend_http_settings {
    name                                = "http-settings"
    cookie_based_affinity               = "Disabled"
    port                               = 80
    protocol                           = "Http"
    request_timeout                    = 60
    pick_host_name_from_backend_address = true
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "frontend-ip-config"
    frontend_port_name            = "frontend-port"
    protocol                      = "Http"
  }

  request_routing_rule {
    name                       = "routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "http-settings"
    priority                   = 1
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

output "webapp_url" {
  value = azurerm_linux_web_app.web_app.default_hostname
}

output "web_app_name" {
  
  value = azurerm_linux_web_app.web_app.name
}

output "webapp_url_2" {
  value = azurerm_linux_web_app.web_app_2.default_hostname
}

output "web_app_name_2" {
  
  value = azurerm_linux_web_app.web_app_2.name
}

output "application_gateway_ip" {
  value = azurerm_public_ip.pip.ip_address
}