variable "image_tag" {
    type = string
    default = "latest"
}

variable "resource_group_name" {
    type = string
    default = "azure-quest-rg"
}

variable "secret_word_value" {
    type      = string
    sensitive = true
    default   = "placeholder"
}

variable "cloudflare_zone_id" {
    type = string
}