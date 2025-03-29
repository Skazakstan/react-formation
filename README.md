# Infrastructure Terraform avec stockage S3

Ce projet utilise Terraform pour déployer l'infrastructure, avec stockage d'état sur S3 et déploiement via GitHub Actions utilisant OIDC pour l'authentification AWS.

## Prérequis

- AWS CLI configuré
- Terraform v1.5.0+
- Accès AWS avec les permissions nécessaires
- Configuration OIDC entre GitHub et AWS

## Structure du projet

```
terraform/
├── backend.tf                 # Configuration du backend S3
├── provider.tf                # Configuration des providers
├── main.tf                    # Ressources principales
├── variables.tf               # Variables globales
├── terraform.tfvars           # Valeurs par défaut des variables
├── outputs.tf                 # Outputs Terraform
└── setup-remote-state.sh      # Script pour créer le bucket S3
.github/
└── workflows/
    └── terraform-deploy.yml   # Workflow GitHub Actions
iam-policy-example.tf          # Exemple de configuration IAM pour OIDC
```

## Préfixage des ressources

Toutes les ressources sont préfixées avec l'environnement (`dev-`, `prod-`), ce qui permet:

- D'éviter les conflits de noms entre environnements
- D'identifier facilement à quel environnement appartient une ressource
- De gérer différents niveaux d'accès par environnement

## Configuration initiale

1. Créer le fournisseur OIDC et le rôle IAM en utilisant l'exemple dans `iam-policy-example.tf`

2. Exécuter le script de configuration du stockage distant pour l'environnement souhaité:

   ```bash
   # Pour l'environnement dev (par défaut)
   ./terraform/setup-remote-state.sh

   # Pour l'environnement prod
   ./terraform/setup-remote-state.sh prod
   ```

3. Configurer les variables GitHub:
   - `AWS_ACCOUNT_ID`: ID de votre compte AWS (pour le rôle OIDC)

## Déploiement manuel

```bash
cd terraform

# Pour l'environnement dev (par défaut)
terraform init
terraform plan
terraform apply

# Pour l'environnement prod
terraform init
terraform plan -var="environment=prod"
terraform apply -var="environment=prod"
```

## Déploiement automatisé

Le déploiement est automatiquement déclenché par:

- **Push sur main**: déploie en environnement **prod**
- **Pull Request**:
  nt **dev**

Le workflow utilise l'authentification OIDC avec AWS, éliminant le besoin de stocker des secrets AWS à long terme.

## Notes importantes

- Le stockage d'état utilise uniquement S3 sans mécanisme de verrouillage (pas de DynamoDB)
- Attention aux modifications simultanées qui pourraient causer des conflits d'état
- L'authentification OIDC est plus sécurisée que l'utilisation de clés d'accès statiques
