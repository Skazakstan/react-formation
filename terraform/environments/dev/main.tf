module "infrastructure" {
  source = "../../modules/infrastructure"

  environment = "dev"
  project_name = "my-terraform-project"
} 