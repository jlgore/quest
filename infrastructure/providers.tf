terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.32.1"
    }
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.61.0"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "5.17.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.0"
    }
  }
}

provider "azapi" {}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}

provider "azurerm" {
  # Configuration options
  features {}
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
  #account_id = var.cloudflare_account_id
}