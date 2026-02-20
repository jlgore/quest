output "azure_container_app_fqdn" {
  value       = azurerm_container_app.this.ingress[0].fqdn
  description = "FQDN of the Azure Container App"
}
