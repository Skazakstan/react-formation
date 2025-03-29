terraform {
  backend "s3" {
    bucket         = "mon-bucket-terraform-state"
    key            = "terraform.tfstate"
    region         = "eu-west-3"
    encrypt        = true
  }
} 