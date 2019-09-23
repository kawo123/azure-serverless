provider "azurerm" {
    version = "=1.33.1"
}

resource "azurerm_resource_group" "serverless-rg" {
  name     = "${var.prefix}-rg"
  location = "${var.location}"
}

resource "azurerm_storage_account" "serverless-storage" {
  name                     = "${replace(lower(var.prefix), "-", "")}storage"
  resource_group_name      = "${azurerm_resource_group.serverless-rg.name}"
  location                 = "${azurerm_resource_group.serverless-rg.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "serverless-storage-container" {
  name                  = "${var.prefix}-container"
  resource_group_name   = "${azurerm_resource_group.serverless-rg.name}"
  storage_account_name  = "${azurerm_storage_account.serverless-storage.name}"
  container_access_type = "private"
}

resource "azurerm_application_insights" "serverless-appinsight" {
  name                = "${var.prefix}-appinsight"
  location            = "${azurerm_resource_group.serverless-rg.location}"
  resource_group_name = "${azurerm_resource_group.serverless-rg.name}"
  application_type    = "Node.JS"
}

resource "azurerm_app_service_plan" "serverless-app-plan" {
  name                = "${var.prefix}-app-plan"
  location            = "${azurerm_resource_group.serverless-rg.location}"
  resource_group_name = "${azurerm_resource_group.serverless-rg.name}"
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "serverless-function" {
  name                      = "${var.prefix}-functions"
  location                  = "${azurerm_resource_group.serverless-rg.location}"
  resource_group_name       = "${azurerm_resource_group.serverless-rg.name}"
  app_service_plan_id       = "${azurerm_app_service_plan.serverless-app-plan.id}"
  storage_connection_string = "${azurerm_storage_account.serverless-storage.primary_connection_string}"
  version                   = "~2"
  app_settings = {
    "WEBSITE_NODE_DEFAULT_VERSION" = "10.14.1"
    "APPINSIGHTS_INSTRUMENTATIONKEY" = "${azurerm_application_insights.serverless-appinsight.instrumentation_key}"
  }
}
