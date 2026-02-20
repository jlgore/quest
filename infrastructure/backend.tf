terraform {
  backend "s3" {
    acl          = "bucket-owner-full-control"
    bucket       = "shartdotcloud-tf-state"
    key          = "quest/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}