# Exemple de configuration Terraform pour créer le rôle IAM OIDC GitHub Actions
# À ajouter à votre infrastructure Terraform ou à utiliser comme référence

# Fournisseur GitHub OIDC
resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]  # GitHub OIDC thumbprint
}

# Rôle IAM pour GitHub Actions
resource "aws_iam_role" "github_actions_terraform" {
  name = "github-actions-terraform-role"
  
  # Politique de confiance permettant à GitHub Actions d'assumer ce rôle
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_actions.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
          }
          StringLike = {
            # Autorise uniquement les workflows de votre repository
            # Format: OWNER/REPO:ref:REF ou OWNER/REPO:environment:NAME
            "token.actions.githubusercontent.com:sub": "repo:${var.github_repository}:*"
          }
        }
      }
    ]
  })
}

# Politique d'autorisation pour exécuter Terraform
resource "aws_iam_policy" "terraform_execution_policy" {
  name        = "terraform-execution-policy"
  description = "Permet à Terraform de déployer l'infrastructure"
  
  policy = jsonencode({
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
          "s3:GetBucketVersioning",
          "s3:PutBucketVersioning",
          "s3:GetBucketPolicy",
          "s3:PutBucketPolicy",
          "s3:GetBucketTagging",
          "s3:PutBucketTagging",
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::dev-${var.project_name}-app-bucket",
          "arn:aws:s3:::dev-${var.project_name}-app-bucket/*",
          "arn:aws:s3:::prod-${var.project_name}-app-bucket",
          "arn:aws:s3:::prod-${var.project_name}-app-bucket/*"
        ]
      },
      # Autres autorisations selon vos besoins
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attacher la politique au rôle
resource "aws_iam_role_policy_attachment" "github_actions_terraform_policy" {
  role       = aws_iam_role.github_actions_terraform.name
  policy_arn = aws_iam_policy.terraform_execution_policy.arn
}

# Variables nécessaires
variable "github_repository" {
  type        = string
  description = "GitHub repository format: OWNER/REPO"
  default     = "Skazakstan/react-formation"
}

variable "project_name" {
  type        = string
  description = "Nom du projet"
  default     = "my-terraform-project"
} 