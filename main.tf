# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.0"
    }
  }
  required_version = ">= 0.14.9"
}
provider "azurerm" {
  features {}
}

variable "zip_path" {
  type = string
  default = "/actions-runner/_work/javaexample/javaexample/teste/target/ArtifactSample-0.0.1.war"

}

resource "random_integer" "ri" {
  min = 10000
  max = 99999
}


# Create the Linux App Service Plan
resource "azurerm_service_plan" "appserviceplan" {
  name                = "webapp-service-${random_integer.ri.result}"
  location            = "West Europe"
  resource_group_name = "myapp-rg"
  os_type             = "Linux"
  sku_name            = "B1"
}

# Create the web app, pass in the App Service Plan ID
resource "azurerm_linux_web_app" "webapp" {
  name                  = "webapp-java-${random_integer.ri.result}"
  location              = "West Europe"
  resource_group_name   = "myapp-rg"
  service_plan_id       = azurerm_service_plan.appserviceplan.id
  https_only            = true
  zip_deploy_file       = var.zip_path
  
  site_config { 
    application_stack {
    java_server = "TOMCAT"
    }
    minimum_tls_version = "1.2"
  }
  
}

