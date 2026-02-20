module "aws" {
  source = "./modules/aws"

  vpc_id             = var.aws_vpc_id
  cloudflare_zone_id = var.cloudflare_zone_id
  image_tag          = var.image_tag
  secret_word_value  = var.secret_word_value
}
