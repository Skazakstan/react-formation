output "app_bucket_name" {
  description = "Nom du bucket S3 de l'application"
  value       = aws_s3_bucket.app_bucket.bucket
}

output "app_bucket_arn" {
  description = "ARN du bucket S3 de l'application"
  value       = aws_s3_bucket.app_bucket.arn
} 