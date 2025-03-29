resource "aws_s3_bucket" "app_bucket" {
  bucket = "${var.environment}-${var.project_name}-app-bucket"
  
  tags = {
    Name        = "${var.environment}-app-bucket"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "app_bucket_versioning" {
  bucket = aws_s3_bucket.app_bucket.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Commentaires pour les futures ressources:
# Préfixez toujours les nouvelles ressources avec ${var.environment}-
# Exemples:
# - "${var.environment}-lambda-function"
# - "${var.environment}-dynamodb-table"
# - "${var.environment}-app-role"
#
# Et ajoutez systématiquement des tags d'environnement:
# tags = {
#   Name        = "${var.environment}-ressource-name"
#   Environment = var.environment
# } 