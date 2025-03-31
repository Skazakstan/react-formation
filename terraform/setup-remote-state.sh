#!/bin/bash

# Ce script crée le bucket S3 qui stockera l'état Terraform.
# Il doit être exécuté une seule fois avant de commencer à utiliser Terraform.
# Usage: ./setup-remote-state.sh [env]
#   env: Environnement (dev ou prod). Par défaut: dev

# Variables
ENV=${1:-dev}
PROJECT_NAME="react-formation"
BUCKET_NAME="${ENV}-${PROJECT_NAME}-terraform-state"
REGION="eu-west-1"

echo "==================================================================="
echo "Configuration du stockage d'état Terraform pour l'environnement: $ENV"
echo "==================================================================="
echo ""
echo "Ce script va créer le bucket S3 pour stocker l'état Terraform."
echo "Bucket: $BUCKET_NAME"
echo "Région: $REGION"
echo ""
echo "Remarque: Le fichier backend.tf sera généré dynamiquement par le pipeline CI/CD."
echo ""

read -p "Continuer? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Opération annulée."
    exit 1
fi

echo "Création du bucket S3 pour l'environnement: $ENV"

# Création du bucket S3
aws s3api create-bucket \
    --bucket $BUCKET_NAME \
    --region $REGION \
    --create-bucket-configuration LocationConstraint=$REGION

if [ $? -ne 0 ]; then
    echo "Erreur lors de la création du bucket. Vérifiez les logs ci-dessus."
    exit 1
fi

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

echo ""
echo "==================================================================="
echo "✅ Configuration du backend S3 terminée pour l'environnement $ENV!"
echo "==================================================================="
echo ""
echo "Bucket créé: $BUCKET_NAME"
echo ""
echo "Dans le CI/CD, le fichier backend.tf sera généré automatiquement."
echo "Pour un développement local, utilisez cette configuration:"
echo ""
echo "terraform {"
echo "  backend \"s3\" {"
echo "    bucket         = \"$BUCKET_NAME\""
echo "    key            = \"terraform.tfstate\""
echo "    region         = \"$REGION\""
echo "    encrypt        = true"
echo "  }"
echo "}"
echo ""
echo "Vous pouvez maintenant exécuter: terraform init" 