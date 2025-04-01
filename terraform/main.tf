# Ajout d'un bloc locals pour améliorer la gestion des domaines
locals {
  # Utiliser le domaine parent spécifié ou l'extraire automatiquement du domaine complet
  parent_domain = var.parent_domain != "" ? var.parent_domain : (
    var.domain_name != "" ? join(".", slice(split(".", var.domain_name), length(split(".", var.domain_name)) - 2, length(split(".", var.domain_name)))) : ""
  )

  # Déterminer si le domaine est un sous-domaine ou le domaine racine
  is_subdomain = var.domain_name != "" && var.domain_name != local.parent_domain && var.domain_name != "www.${local.parent_domain}"

  # Préfixe du sous-domaine (pour nextjs.example.com, ce serait "nextjs")
  subdomain_prefix = local.is_subdomain ? element(split(".", var.domain_name), 0) : ""

  # Nom de domaine complet basé sur l'environnement
  domain_prefix    = var.environment == "prod" ? "" : "${var.environment}-"
  full_domain_name = var.domain_name != "" ? var.domain_name : "${local.domain_prefix}nextjs.${local.parent_domain}"
}

resource "aws_s3_bucket" "app_bucket" {
  bucket = "${var.environment}-${var.project_name}-app-bucket"

  tags = {
    Name        = "${var.environment}-app-bucket"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "app_bucket_public_access" {
  bucket = aws_s3_bucket.app_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "app_website" {
  bucket = aws_s3_bucket.app_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html" # Renvoie vers index.html pour toutes les erreurs (comportement SPA)
  }
}

resource "aws_s3_bucket_policy" "app_bucket_policy" {
  bucket     = aws_s3_bucket.app_bucket.id
  depends_on = [aws_s3_bucket_public_access_block.app_bucket_public_access]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.app_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_versioning" "app_bucket_versioning" {
  bucket = aws_s3_bucket.app_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Gardé temporairement pour éviter les erreurs de dépendance
# Sera supprimé lors d'une prochaine application après dissociation complète
resource "aws_cloudfront_origin_access_control" "app_oac" {
  name                              = "${var.environment}-${var.project_name}-oac"
  description                       = "OAC pour l'accès au bucket S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_acm_certificate" "app_certificate" {
  count             = local.full_domain_name != "" ? 1 : 0
  provider          = aws.us_east_1
  domain_name       = local.full_domain_name
  validation_method = "DNS"

  # Ajouter un nom alternatif pour le domaine www si nécessaire
  subject_alternative_names = var.create_root_domain_record && local.is_subdomain ? ["www.${local.parent_domain}"] : []

  tags = {
    Name        = "${var.environment}-${var.project_name}-certificate"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Récupération de la zone DNS Route53 
data "aws_route53_zone" "main_domain" {
  count        = local.full_domain_name != "" && var.create_dns_record ? 1 : 0
  name         = local.parent_domain
  private_zone = false
}

# Validation du certificat avec Route53
resource "aws_route53_record" "cert_validation" {
  for_each = local.full_domain_name != "" && var.create_dns_record ? {
    for dvo in aws_acm_certificate.app_certificate[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.main_domain[0].zone_id
}

# Attendre la validation du certificat
resource "aws_acm_certificate_validation" "cert_validation" {
  count                   = local.full_domain_name != "" && var.create_dns_record ? 1 : 0
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.app_certificate[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# Enregistrement DNS pour le sous-domaine (exemple: nextjs.stansk.com)
resource "aws_route53_record" "app_domain" {
  count   = local.full_domain_name != "" && var.create_dns_record ? 1 : 0
  zone_id = data.aws_route53_zone.main_domain[0].zone_id
  name    = local.full_domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.app_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.app_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

# Enregistrement DNS pour www si demandé (exemple: www.stansk.com)
resource "aws_route53_record" "www_domain" {
  count   = local.full_domain_name != "" && var.create_dns_record && var.create_root_domain_record && local.is_subdomain ? 1 : 0
  zone_id = data.aws_route53_zone.main_domain[0].zone_id
  name    = "www.${local.parent_domain}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.app_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.app_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_cloudfront_distribution" "app_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"
  comment             = "${var.environment} ${var.project_name} Distribution"

  # Ajouter les noms de domaines alternatifs (conditionnellement)
  aliases = local.full_domain_name != "" ? (
    var.create_root_domain_record && local.is_subdomain ?
    [local.full_domain_name, "www.${local.parent_domain}"] :
    [local.full_domain_name]
  ) : []

  origin {
    domain_name = aws_s3_bucket_website_configuration.app_website.website_endpoint
    origin_id   = "S3-${var.environment}-${var.project_name}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only" # L'endpoint de site web S3 ne supporte que HTTP
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = "S3-${var.environment}-${var.project_name}"
    viewer_protocol_policy = "redirect-to-https"

    cache_policy_id          = aws_cloudfront_cache_policy.app_cache_policy.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.app_request_policy.id
  }

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  dynamic "viewer_certificate" {
    for_each = local.full_domain_name != "" ? [1] : []
    content {
      acm_certificate_arn      = var.create_dns_record ? aws_acm_certificate_validation.cert_validation[0].certificate_arn : aws_acm_certificate.app_certificate[0].arn
      ssl_support_method       = "sni-only"
      minimum_protocol_version = "TLSv1.2_2021"
    }
  }

  dynamic "viewer_certificate" {
    for_each = local.full_domain_name == "" ? [1] : []
    content {
      cloudfront_default_certificate = true
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name        = "${var.environment}-${var.project_name}-distribution"
    Environment = var.environment
  }
}

resource "aws_cloudfront_cache_policy" "app_cache_policy" {
  name        = "${var.environment}-${var.project_name}-cache-policy"
  comment     = "Cache policy for ${var.project_name} ${var.environment}"
  default_ttl = 86400
  max_ttl     = 31536000
  min_ttl     = 1

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true
  }
}

resource "aws_cloudfront_origin_request_policy" "app_request_policy" {
  name    = "${var.environment}-${var.project_name}-request-policy"
  comment = "Request policy for ${var.project_name} ${var.environment}"

  cookies_config {
    cookie_behavior = "none"
  }

  headers_config {
    header_behavior = "whitelist"
    headers {
      items = ["Origin", "Access-Control-Request-Method", "Access-Control-Request-Headers", "Referer"]
    }
  }

  query_strings_config {
    query_string_behavior = "all"
  }
}
