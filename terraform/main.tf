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