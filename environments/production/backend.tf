terraform {
  backend "s3" {
    bucket       = "musharaf-terraform-state-215514708499-2026"
    key          = "production/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
