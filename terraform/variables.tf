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
  default     = "nextjs-formation"
}

variable "domain_name" {
  description = "Nom de domaine personnalisé pour le site (laisser vide pour utiliser le domaine CloudFront par défaut)"
  type        = string
  default     = ""
}

variable "create_dns_record" {
  description = "Créer automatiquement les enregistrements DNS dans Route53 (nécessite une zone hébergée existante pour le domaine parent)"
  type        = bool
  default     = false
}

variable "parent_domain" {
  description = "Domaine parent pour la zone Route53 (par défaut, extrait automatiquement du domain_name)"
  type        = string
  default     = ""
}

variable "create_root_domain_record" {
  description = "Créer également un enregistrement pour le domaine racine (www)"
  type        = bool
  default     = false
}

variable "allowed_ips" {
  description = "Liste des adresses IP autorisées à accéder directement au bucket S3 (laissez vide pour restreindre à CloudFront uniquement)"
  type        = list(string)
  default     = [] # "0.0.0.0/0" permet l'accès depuis n'importe où
}
