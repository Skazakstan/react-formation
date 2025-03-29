module "infrastructure" {
  source = "../../modules/infrastructure"

  environment  = "prod"
  project_name = var.project_name
} 