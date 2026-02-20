terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
    azapi = {
      source = "Azure/azapi"
    }
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = "East US"
}

resource "azurerm_key_vault" "this" {
  name                       = "azure-quest-kv"
  location                   = azurerm_resource_group.this.location
  resource_group_name        = azurerm_resource_group.this.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled  = true
  soft_delete_retention_days = 7
}

resource "azurerm_key_vault_secret" "secret_word" {
  name         = "secret-word"
  value        = var.secret_word_value
  key_vault_id = azurerm_key_vault.this.id
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = "azure-quest-law-01"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "this" {
  name                       = "Azure-Quest-Environment"
  location                   = azurerm_resource_group.this.location
  resource_group_name        = azurerm_resource_group.this.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
}

resource "azurerm_container_app" "this" {
  name                         = "azure-quest-aca"
  container_app_environment_id = azurerm_container_app_environment.this.id
  resource_group_name          = azurerm_resource_group.this.name
  revision_mode                = "Single"

  identity {
    type = "SystemAssigned"
  }

  secret {
    name                = "secret-word"
    identity            = "System"
    key_vault_secret_id = azurerm_key_vault_secret.secret_word.versionless_id
  }

  template {
    container {
      name   = "quest"
      image  = "ghcr.io/jlgore/quest:${var.image_tag}"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name        = "SECRET_WORD"
        secret_name = "secret-word"
      }
    }
  }

  ingress {
    external_enabled = true
    target_port      = 3000

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

resource "azurerm_role_assignment" "quest_kv_access" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_container_app.this.identity[0].principal_id
}