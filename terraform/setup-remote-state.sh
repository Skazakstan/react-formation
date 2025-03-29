#!/bin/bash

# Variables
ENV=${1:-dev}
PROJECT_NAME="react-formation"
BUCKET_NAME="${ENV}-${PROJECT_NAME}-terraform-state"
REGION="eu-west-1"

echo "Création du bucket S3 pour l'environnement: $ENV"

# Création du bucket S3
aws s3api create-bucket \
    --bucket $BUCKET_NAME \
    --region $REGION \
    --create-bucket-configuration LocationConstraint=$REGION

# Activation du versionnement
aws s3api put-bucket-versioning \
    --bucket $BUCKET_NAME \
    --versioning-configuration Status=Enabled

# Activation du chiffrement
aws s3api put-bucket-encryption \
    --bucket $BUCKET_NAME \
    --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'

# Ajouter des tags
aws s3api put-bucket-tagging \
    --bucket $BUCKET_NAME \
    --tagging 'TagSet=[{Key=Environment,Value='$ENV'},{Key=ManagedBy,Value=Terraform}]'

echo "Configuration du backend S3 terminée pour l'environnement $ENV!"
echo "Bucket créé: $BUCKET_NAME"
echo ""
echo "Pour utiliser ce backend, mettez à jour votre fichier backend.tf:"
echo "terraform {"
echo "  backend \"s3\" {"
echo "    bucket         = \"$BUCKET_NAME\""
echo "    key            = \"terraform.tfstate\""
echo "    region         = \"$REGION\""
echo "    encrypt        = true"
echo "  }"
echo "}" 