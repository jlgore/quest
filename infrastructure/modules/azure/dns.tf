# CNAME pointing quest.azure.shart.cloud to the Container App FQDN
resource "cloudflare_dns_record" "quest" {
  zone_id = var.cloudflare_zone_id
  name    = "quest.azure"
  type    = "CNAME"
  content = azurerm_container_app.this.ingress[0].fqdn
  ttl     = 1
  proxied = false
}

# TXT record for custom domain verification
resource "cloudflare_dns_record" "quest_verification" {
  zone_id = var.cloudflare_zone_id
  name    = "asuid.quest.azure"
  type    = "TXT"
  content = azurerm_container_app.this.custom_domain_verification_id
  ttl     = 1
  proxied = false
}

# Step 1: Add custom domain to the Container App (no cert yet)
resource "azurerm_container_app_custom_domain" "quest" {
  container_app_id         = azurerm_container_app.this.id
  name                     = "quest.azure.shart.cloud"
  certificate_binding_type = "Disabled"

  depends_on = [cloudflare_dns_record.quest, cloudflare_dns_record.quest_verification]

  lifecycle {
    ignore_changes = [certificate_binding_type, container_app_environment_certificate_id]
  }
}

# Step 2: Create managed certificate (requires custom domain to exist first)
resource "azapi_resource" "managed_certificate" {
  type      = "Microsoft.App/managedEnvironments/managedCertificates@2024-03-01"
  name      = "quest-azure-managed-cert"
  parent_id = azurerm_container_app_environment.this.id
  location  = azurerm_resource_group.this.location

  body = {
    properties = {
      subjectName             = "quest.azure.shart.cloud"
      domainControlValidation = "CNAME"
    }
  }

  depends_on = [azurerm_container_app_custom_domain.quest]
}

# Step 3: Bind the managed cert to the custom domain
resource "azapi_update_resource" "bind_managed_cert" {
  type        = "Microsoft.App/containerApps@2024-03-01"
  resource_id = azurerm_container_app.this.id

  body = {
    properties = {
      configuration = {
        ingress = {
          customDomains = [
            {
              name          = "quest.azure.shart.cloud"
              bindingType   = "SniEnabled"
              certificateId = azapi_resource.managed_certificate.id
            }
          ]
        }
      }
    }
  }

  depends_on = [azapi_resource.managed_certificate]
}
