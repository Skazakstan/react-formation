module "infrastructure" {
  source = "../../modules/infrastructure"

  environment  = "dev"
  project_name = var.project_name
} 