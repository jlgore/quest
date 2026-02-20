output "aws_lb_url" {
  value       = module.aws.aws_lb_url
  description = "DNS name of the AWS ALB"
}

output "azure_container_app_fqdn" {
  value       = module.azure.azure_container_app_fqdn
  description = "FQDN of the Azure Container App"
}
