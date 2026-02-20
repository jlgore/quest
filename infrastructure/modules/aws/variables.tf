variable "deployment_secret_word" {
    type        = string
    description = "Name of the secret in Secrets Manager"
    default     = "quest-secret-word"
}

variable "secret_word_value" {
    type        = string
    sensitive   = true
    description = "The actual secret value stored in Secrets Manager"
}

variable "ecs_cluster_name" {
    type = string
    default = "quest"
}

variable "ecs_cluster_insights_available" {
    type = string
    default = "disabled"
}

variable "image_tag" {
    type = string
    default = "latest"
}

variable "vpc_id" {
    type = string
}

variable "domain_name" {
    type = string
    default = "quest.aws.shart.cloud"
}

variable "cloudflare_zone_id" {
    type        = string
    description = "Cloudflare Zone ID for the shart.cloud domain"
}

variable "aws_region" {
    type = string
    description = "The AWS Region you wish to deploy to / where your backend bucket is"
    default = "us-east-1" # the region that is so good when it goes down it takes other regions with it. pure talent. nobody does it better.
}