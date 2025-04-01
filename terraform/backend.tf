terraform {
  backend "s3" {
    bucket  = "dev-nextjs-formation-terraform-state"
    key     = "terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }
}
