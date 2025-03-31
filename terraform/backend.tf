terraform {
  backend "s3" {
    bucket         = "dev-react-formation-terraform-state"
    key            = "terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
  }
} 