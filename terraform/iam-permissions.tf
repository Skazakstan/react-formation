# Politique d'autorisation pour exécuter Terraform avec CloudFront, S3 et Route53
# Utilisez ce fichier comme référence pour mettre à jour la politique de votre rôle IAM

locals {
  terraform_permissions_policy = {
    Version = "2012-10-17"
    Statement = [
      # Autorisations S3 pour l'état Terraform
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::dev-${var.project_name}-terraform-state",
          "arn:aws:s3:::dev-${var.project_name}-terraform-state/*",
          "arn:aws:s3:::prod-${var.project_name}-terraform-state",
          "arn:aws:s3:::prod-${var.project_name}-terraform-state/*"
        ]
      },
      # Autorisations pour gérer les buckets S3 de l'application
      {
        Effect = "Allow"
        Action = [
          "s3:CreateBucket",
          "s3:DeleteBucket",
          "s3:GetBucketVersioning",
          "s3:PutBucketVersioning",
          "s3:GetBucketPolicy",
          "s3:PutBucketPolicy",
          "s3:GetBucketWebsite",
          "s3:PutBucketWebsite",
          "s3:GetBucketTagging",
          "s3:PutBucketTagging",
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:PutBucketCORS",
          "s3:GetBucketCORS"
        ]
        Resource = [
          "arn:aws:s3:::dev-${var.project_name}-app-bucket",
          "arn:aws:s3:::dev-${var.project_name}-app-bucket/*",
          "arn:aws:s3:::prod-${var.project_name}-app-bucket",
          "arn:aws:s3:::prod-${var.project_name}-app-bucket/*"
        ]
      },
      # Autorisations CloudFront
      {
        Effect = "Allow"
        Action = [
          "cloudfront:CreateDistribution",
          "cloudfront:UpdateDistribution",
          "cloudfront:DeleteDistribution",
          "cloudfront:GetDistribution",
          "cloudfront:ListDistributions",
          "cloudfront:CreateCloudFrontOriginAccessIdentity",
          "cloudfront:GetCloudFrontOriginAccessIdentity",
          "cloudfront:DeleteCloudFrontOriginAccessIdentity",
          "cloudfront:CreateInvalidation",
          "cloudfront:GetInvalidation",
          "cloudfront:ListInvalidations",
          "cloudfront:CreateCachePolicy",
          "cloudfront:GetCachePolicy",
          "cloudfront:UpdateCachePolicy",
          "cloudfront:DeleteCachePolicy",
          "cloudfront:CreateOriginRequestPolicy",
          "cloudfront:GetOriginRequestPolicy",
          "cloudfront:UpdateOriginRequestPolicy",
          "cloudfront:DeleteOriginRequestPolicy", 
          "cloudfront:CreateOriginAccessControl",
          "cloudfront:GetOriginAccessControl",
          "cloudfront:UpdateOriginAccessControl",
          "cloudfront:DeleteOriginAccessControl"
        ]
        Resource = "*"
      },
      # Autorisations ACM pour les certificats SSL
      {
        Effect = "Allow"
        Action = [
          "acm:RequestCertificate",
          "acm:DescribeCertificate",
          "acm:DeleteCertificate",
          "acm:ListCertificates",
          "acm:AddTagsToCertificate"
        ]
        Resource = "*"
      },
      # Autorisations Route53 complètes pour la gestion DNS
      {
        Effect = "Allow"
        Action = [
          "route53:ListHostedZones",
          "route53:GetHostedZone",
          "route53:ListResourceRecordSets",
          "route53:ChangeResourceRecordSets",
          "route53:CreateHealthCheck",
          "route53:GetHealthCheck",
          "route53:DeleteHealthCheck",
          "route53:UpdateHealthCheck",
          "route53:GetChange"
        ]
        Resource = "*"
      }
    ]
  }
}

# Sortie formatée pour JSON à copier/coller dans la console AWS IAM
output "iam_policy_json" {
  value = jsonencode(local.terraform_permissions_policy)
} 