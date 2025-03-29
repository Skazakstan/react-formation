terraform {
  backend "s3" {
    bucket         = "dev-my-terraform-project-terraform-state"
    key            = "terraform.tfstate"
    region         = "eu-west-3"
    encrypt        = true
  }
} 