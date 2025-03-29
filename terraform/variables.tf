variable "aws_region" {
  description = "Région AWS à utiliser"
  type        = string
  default     = "eu-west-1"
}

variable "environment" {
  description = "Environnement (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Nom du projet"
  type        = string
  default     = "react-formation"
} 