output "app_bucket_name" {
  description = "Nom du bucket S3 de l'application"
  value       = aws_s3_bucket.app_bucket.bucket
}

output "app_bucket_arn" {
  description = "ARN du bucket S3 de l'application"
  value       = aws_s3_bucket.app_bucket.arn
}

output "cloudfront_distribution_id" {
  description = "ID de la distribution CloudFront"
  value       = aws_cloudfront_distribution.app_distribution.id
}

output "cloudfront_domain_name" {
  description = "Nom de domaine CloudFront"
  value       = aws_cloudfront_distribution.app_distribution.domain_name
}

output "website_url" {
  description = "URL du site web"
  value       = local.full_domain_name != "" ? "https://${local.full_domain_name}" : "https://${aws_cloudfront_distribution.app_distribution.domain_name}"
}

output "domain_name" {
  description = "Nom de domaine complet utilisé pour ce déploiement"
  value       = local.full_domain_name
}

output "environment" {
  description = "Environnement actuel du déploiement"
  value       = var.environment
}

output "dns_records" {
  description = "Informations sur les enregistrements DNS créés"
  value = {
    zone_id     = local.full_domain_name != "" && var.create_dns_record ? data.aws_route53_zone.main_domain[0].zone_id : null
    parent_zone = local.full_domain_name != "" && var.create_dns_record ? data.aws_route53_zone.main_domain[0].name : null
    records = {
      main = local.full_domain_name != "" && var.create_dns_record ? aws_route53_record.app_domain[0].name : null
      www  = local.full_domain_name != "" && var.create_dns_record && var.create_root_domain_record && local.is_subdomain ? aws_route53_record.www_domain[0].name : null
    }
  }
} 