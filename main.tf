terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id                 = var.subscription_id
  resource_provider_registrations = "none"
}

variable "subscription_id" {
  type = string
}

# 1) Look up the workspace you ALREADY built in the HyenLo project
data "azurerm_log_analytics_workspace" "hyenlo" {
  name                = "law-hyenlo"
  resource_group_name = "rg-hyenlo-tf"
}

# 2) Turn Microsoft Sentinel on for that workspace
resource "azurerm_sentinel_log_analytics_workspace_onboarding" "main" {
  workspace_id = data.azurerm_log_analytics_workspace.hyenlo.id
}
# Look up the subscription you're signed in to
data "azurerm_subscription" "current" {}

# Send the subscription's Activity log to law-hyenlo
resource "azurerm_monitor_diagnostic_setting" "activity" {
  name                       = "diag-activity-to-law"
  target_resource_id         = data.azurerm_subscription.current.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.hyenlo.id

  enabled_log {
    category = "Administrative"
  }
  enabled_log {
    category = "Security"
  }
  enabled_log {
    category = "Policy"
  }
  enabled_log {
    category = "Alert"
  }
}