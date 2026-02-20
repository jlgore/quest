terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.32.1"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "5.17.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}


provider "cloudflare" {
  api_token = var.cloudflare_api_token
  #account_id = var.cloudflare_account_id
}