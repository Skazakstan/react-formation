# Infrastructure Terraform avec stockage S3

Ce projet utilise Terraform pour déployer l'infrastructure, avec stockage d'état sur S3 et déploiement via GitHub Actions.

## Prérequis

- AWS CLI configuré
- Terraform v1.5.0+
- Accès AWS avec les permissions nécessaires

## Structure du projet

```
terraform/
├── backend.tf                 # Configuration du backend S3
├── provider.tf                # Configuration des providers
├── variables.tf               # Variables globales
├── setup-remote-state.sh      # Script pour créer le bucket S3
├── environments/              # Environnements spécifiques
│   ├── dev/                   # Environnement de développement
│   │   └── main.tf            # Configuration dev
│   └── prod/                  # Environnement de production
└── modules/                   # Modules Terraform réutilisables
    └── infrastructure/        # Module infrastructure
        ├── main.tf            # Ressources
        ├── variables.tf       # Variables du module
        └── outputs.tf         # Outputs du module
.github/
└── workflows/
    └── terraform-deploy.yml   # Workflow GitHub Actions
```

## Configuration initiale

1. Exécuter le script de configuration du stockage distant :

   ```bash
   ./terraform/setup-remote-state.sh
   ```

2. Configurer les secrets GitHub :
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

## Déploiement manuel

```bash
cd terraform/environments/dev
terraform init
terraform plan
terraform apply
```

## Déploiement automatisé

Le déploiement est automatiquement déclenché par les push sur la branche `main` ou les pull requests.

## Notes importantes

- Le stockage d'état utilise uniquement S3 sans mécanisme de verrouillage (pas de DynamoDB)
- Attention aux modifications simultanées qui pourraient causer des conflits d'état
