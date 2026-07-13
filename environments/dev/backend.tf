terraform {
  backend "s3" {
    bucket = "tf-prod-s3-bucket-13-july"
    key = "terraform.tfstate"
    region = "us-east-1"
  }
}