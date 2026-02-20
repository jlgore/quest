variable "aws_vpc_id" {
  type        = string
  description = "VPC ID for the AWS ECS deployment"
}

variable "cloudflare_zone_id" {
  type        = string
  description = "Cloudflare Zone ID for the shart.cloud domain"
}

variable "cloudflare_account_id" {
  type = string
}

variable "cloudflare_api_token" {
  type = string
}

variable "image_tag" {
  type        = string
  default     = "latest"
  description = "Container image tag to deploy"
}

variable "secret_word_value" {
  type        = string
  sensitive   = true
  description = "The actual secret value stored in Secrets Manager"
  default = "placeholder"
}

variable "aws_region" {
  type = string
  description = "AWS Region variable passed to providers.tf"
  default = "us-east-1"
}